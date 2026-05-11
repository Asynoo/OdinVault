class CsvEntry {
  final String title;
  final String username;
  final String password;
  final String url;
  final String notes;

  const CsvEntry({
    required this.title,
    required this.username,
    required this.password,
    required this.url,
    required this.notes,
  });
}

class CsvImportResult {
  final String format;
  final List<CsvEntry> entries;

  const CsvImportResult(this.format, this.entries);
}

class CsvImportService {
  static CsvImportResult? parse(String content) {
    final lines = content
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    if (lines.length < 2) return null;

    final rawHeaders = _parseLine(lines[0]);
    final idx = {
      for (var i = 0; i < rawHeaders.length; i++)
        rawHeaders[i].toLowerCase().trim(): i
    };

    final has = idx.containsKey;
    final rows = lines.skip(1);

    if (has('grouping') && has('url') && has('username') && has('password') && has('name')) {
      return _build('LastPass', rows, idx, _lastPass);
    }
    if (has('login_username') && has('login_password')) {
      return _build('Bitwarden', rows, idx, _bitwarden);
    }
    if (has('type') && has('note') && has('username') && has('password')) {
      return _build('ProtonPass', rows, idx, _protonPass);
    }
    if (has('login') && has('website address')) {
      return _build('Keeper', rows, idx, _keeper);
    }
    if (has('title') && has('username') && has('password')) {
      return _build('1Password', rows, idx, _onePassword);
    }

    return null;
  }

  static CsvEntry? _lastPass(List<String> r, Map<String, int> idx) {
    final url = _get(r, idx, 'url');
    if (url == 'http://sn') return null; // skip secure notes
    final title = _get(r, idx, 'name');
    return CsvEntry(
      title: title.isEmpty ? _domainFromUrl(url) : title,
      username: _get(r, idx, 'username'),
      password: _get(r, idx, 'password'),
      url: url,
      notes: _get(r, idx, 'extra'),
    );
  }

  static CsvEntry? _bitwarden(List<String> r, Map<String, int> idx) {
    if (_get(r, idx, 'type') != 'login') return null;
    return CsvEntry(
      title: _get(r, idx, 'name'),
      username: _get(r, idx, 'login_username'),
      password: _get(r, idx, 'login_password'),
      url: _get(r, idx, 'login_uri'),
      notes: _get(r, idx, 'notes'),
    );
  }

  static CsvEntry? _protonPass(List<String> r, Map<String, int> idx) {
    if (_get(r, idx, 'type') != 'login') return null;
    return CsvEntry(
      title: _get(r, idx, 'name'),
      username: _get(r, idx, 'username'),
      password: _get(r, idx, 'password'),
      url: _get(r, idx, 'url'),
      notes: _get(r, idx, 'note'),
    );
  }

  static CsvEntry? _keeper(List<String> r, Map<String, int> idx) => CsvEntry(
        title: _get(r, idx, 'title'),
        username: _get(r, idx, 'login'),
        password: _get(r, idx, 'password'),
        url: _get(r, idx, 'website address'),
        notes: _get(r, idx, 'notes'),
      );

  static CsvEntry? _onePassword(List<String> r, Map<String, int> idx) => CsvEntry(
        title: _get(r, idx, 'title'),
        username: _get(r, idx, 'username'),
        password: _get(r, idx, 'password'),
        url: _get(r, idx, 'url'),
        notes: _get(r, idx, 'notes'),
      );

  static CsvImportResult? _build(
    String format,
    Iterable<String> rows,
    Map<String, int> idx,
    CsvEntry? Function(List<String>, Map<String, int>) extractor,
  ) {
    final entries = <CsvEntry>[];
    for (final line in rows) {
      if (line.trim().isEmpty) continue;
      final entry = extractor(_parseLine(line), idx);
      if (entry != null && entry.password.isNotEmpty) entries.add(entry);
    }
    if (entries.isEmpty) return null;
    return CsvImportResult(format, entries);
  }

  static String _get(List<String> row, Map<String, int> idx, String key) {
    final i = idx[key];
    if (i == null || i >= row.length) return '';
    return row[i].trim();
  }

  static String _domainFromUrl(String url) {
    try {
      return Uri.parse(url).host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

  static List<String> _parseLine(String line) {
    final fields = <String>[];
    final current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (c == ',' && !inQuotes) {
        fields.add(current.toString());
        current.clear();
      } else {
        current.write(c);
      }
    }
    fields.add(current.toString());
    return fields;
  }
}
