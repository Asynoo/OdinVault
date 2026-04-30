package com.local.vault_pass

import android.app.assist.AssistStructure
import android.os.Build
import android.os.CancellationSignal
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.service.autofill.*
import android.util.Base64
import android.view.View
import android.view.autofill.AutofillId
import android.view.autofill.AutofillValue
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import javax.crypto.Cipher
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

@RequiresApi(Build.VERSION_CODES.O)
class VaultAutofillService : AutofillService() {

    companion object {
        private const val PREFS_FILE = "FlutterSecureStorage"
        private const val KEY_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIHNlY3VyZSBzdG9yYWdlCg"
        private const val AES_KEY_PREF = "${KEY_PREFIX}_aes_key"
    }

    override fun onFillRequest(
        request: FillRequest,
        cancellationSignal: CancellationSignal,
        callback: FillCallback
    ) {
        val structure = request.fillContexts.last().structure
        val fields = parseFields(structure)

        if (fields.usernameId == null && fields.passwordId == null) {
            callback.onSuccess(null)
            return
        }

        val aesKey = readAesKey() ?: run {
            callback.onSuccess(null)
            return
        }

        val query = fields.webDomain ?: structure.activityComponent?.packageName ?: ""
        val entries = readMatchingEntries(aesKey, query)

        if (entries.isEmpty()) {
            callback.onSuccess(null)
            return
        }

        val responseBuilder = FillResponse.Builder()
        for (entry in entries.take(5)) {
            val presentation = RemoteViews(packageName, R.layout.autofill_item).apply {
                setTextViewText(R.id.autofill_title, entry.title)
                setTextViewText(R.id.autofill_subtitle, entry.username)
            }
            val dataset = Dataset.Builder().apply {
                fields.usernameId?.let { setValue(it, AutofillValue.forText(entry.username), presentation) }
                fields.passwordId?.let { setValue(it, AutofillValue.forText(entry.password), presentation) }
            }.build()
            responseBuilder.addDataset(dataset)
        }
        callback.onSuccess(responseBuilder.build())
    }

    override fun onSaveRequest(request: SaveRequest, callback: SaveCallback) {
        callback.onSuccess()
    }

    private fun readAesKey(): String? = try {
        val masterKey = MasterKey.Builder(this)
            .setKeyGenParameterSpec(
                KeyGenParameterSpec.Builder(
                    MasterKey.DEFAULT_MASTER_KEY_ALIAS,
                    KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
                )
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setKeySize(256)
                .build()
            )
            .build()
        EncryptedSharedPreferences.create(
            this,
            PREFS_FILE,
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        ).getString(AES_KEY_PREF, null)
    } catch (_: Exception) {
        null
    }

    private fun readMatchingEntries(aesKey: String, query: String): List<CredentialEntry> {
        val dbFile = getDatabasePath("vaultpass.db")
        if (!dbFile.exists()) return emptyList()
        val results = mutableListOf<CredentialEntry>()
        val db = android.database.sqlite.SQLiteDatabase.openDatabase(
            dbFile.path, null, android.database.sqlite.SQLiteDatabase.OPEN_READONLY
        )
        try {
            db.rawQuery(
                "SELECT title, username, encrypted_password, url FROM passwords ORDER BY title ASC",
                null
            ).use { cursor ->
                while (cursor.moveToNext()) {
                    val title = cursor.getString(0)
                    val username = cursor.getString(1)
                    val encryptedPassword = cursor.getString(2)
                    val url = cursor.getString(3) ?: ""
                    val matches = query.isBlank() ||
                        url.contains(query, ignoreCase = true) ||
                        title.contains(query, ignoreCase = true)
                    if (matches) {
                        try {
                            results += CredentialEntry(title, username, decrypt(encryptedPassword, aesKey))
                        } catch (_: Exception) {}
                    }
                }
            }
        } finally {
            db.close()
        }
        return results
    }

    private fun decrypt(ciphertext: String, base64Key: String): String {
        val key = SecretKeySpec(Base64.decode(base64Key, Base64.DEFAULT), "AES")
        return if (ciphertext.startsWith("gcm:")) {
            val bytes = Base64.decode(ciphertext.removePrefix("gcm:"), Base64.DEFAULT)
            val iv = bytes.copyOfRange(0, 12)
            val data = bytes.copyOfRange(12, bytes.size)
            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
            cipher.init(Cipher.DECRYPT_MODE, key, GCMParameterSpec(128, iv))
            String(cipher.doFinal(data))
        } else {
            val bytes = Base64.decode(ciphertext, Base64.DEFAULT)
            val iv = bytes.copyOfRange(0, 16)
            val data = bytes.copyOfRange(16, bytes.size)
            val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
            cipher.init(Cipher.DECRYPT_MODE, key, IvParameterSpec(iv))
            String(cipher.doFinal(data))
        }
    }

    private fun parseFields(structure: AssistStructure): ParsedFields {
        var usernameId: AutofillId? = null
        var passwordId: AutofillId? = null
        var webDomain: String? = null

        fun traverse(node: AssistStructure.ViewNode) {
            if (node.webDomain != null) webDomain = node.webDomain
            val hints = node.autofillHints ?: emptyArray()
            when {
                hints.any { it == View.AUTOFILL_HINT_USERNAME || it == View.AUTOFILL_HINT_EMAIL_ADDRESS } ->
                    usernameId = node.autofillId
                hints.any { it == View.AUTOFILL_HINT_PASSWORD } ->
                    passwordId = node.autofillId
            }
            for (i in 0 until node.childCount) traverse(node.getChildAt(i))
        }
        for (i in 0 until structure.windowNodeCount) traverse(structure.getWindowNodeAt(i).rootViewNode)

        return ParsedFields(usernameId, passwordId, webDomain)
    }

    private data class ParsedFields(
        val usernameId: AutofillId?,
        val passwordId: AutofillId?,
        val webDomain: String?
    )

    private data class CredentialEntry(val title: String, val username: String, val password: String)
}
