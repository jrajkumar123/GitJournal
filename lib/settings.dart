import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static List<Function> changeObservers = [];

  // singleton
  static final Settings _singleton = Settings._internal();
  factory Settings() => _singleton;
  Settings._internal();
  static Settings get instance => _singleton;

  // Properties
  String gitAuthor = "GitJournal";
  String gitAuthorEmail = "app@gitjournal.io";
  NoteFileNameFormat noteFileNameFormat;

  bool collectUsageStatistics = true;
  bool collectCrashReports = true;

  String yamlModifiedKey = "modified";
  String defaultNewNoteFolder = "journal";

  RemoteSyncFrequency remoteSyncFrequency = RemoteSyncFrequency.Default;
  int version = 0;

  void load(SharedPreferences pref) {
    gitAuthor = pref.getString("gitAuthor") ?? gitAuthor;
    gitAuthorEmail = pref.getString("gitAuthorEmail") ?? gitAuthorEmail;

    noteFileNameFormat = NoteFileNameFormat.fromInternalString(
        pref.getString("noteFileNameFormat"));

    collectUsageStatistics =
        pref.getBool("collectCrashReports") ?? collectUsageStatistics;
    collectCrashReports =
        pref.getBool("collectCrashReports") ?? collectCrashReports;

    yamlModifiedKey = pref.getString("yamlModifiedKey") ?? yamlModifiedKey;
    defaultNewNoteFolder =
        pref.getString("defaultNewNoteFolder") ?? defaultNewNoteFolder;

    remoteSyncFrequency = RemoteSyncFrequency.fromInternalString(
        pref.getString("remoteSyncFrequency"));

    version = pref.getInt("settingsVersion") ?? version;
  }

  Future save() async {
    var pref = await SharedPreferences.getInstance();
    pref.setString("gitAuthor", gitAuthor);
    pref.setString("gitAuthorEmail", gitAuthorEmail);
    pref.setString("noteFileNameFormat", noteFileNameFormat.toInternalString());
    pref.setBool("collectUsageStatistics", collectUsageStatistics);
    pref.setBool("collectCrashReports", collectCrashReports);
    pref.setString("yamlModifiedKey", yamlModifiedKey);
    pref.setString("defaultNewNoteFolder", defaultNewNoteFolder);
    pref.setString(
        "remoteSyncFrequency", remoteSyncFrequency.toInternalString());
    pref.setInt("settingsVersion", version);

    // Shouldn't we check if something has actually changed?
    for (var f in changeObservers) {
      f();
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "gitAuthor": gitAuthor,
      "gitAuthorEmail": gitAuthorEmail,
      "noteFileNameFormat": noteFileNameFormat.toInternalString(),
      "collectUsageStatistics": collectUsageStatistics,
      "collectCrashReports": collectCrashReports,
      "yamlModifiedKey": yamlModifiedKey,
      "defaultNewNoteFolder": defaultNewNoteFolder,
      "version": version,
    };
  }

  Map<String, dynamic> toLoggableMap() {
    var m = toMap();
    m.remove("gitAuthor");
    m.remove("gitAuthorEmail");
    m.remove("defaultNewNoteFolder");
    return m;
  }
}

class NoteFileNameFormat {
  static const Iso8601WithTimeZone =
      NoteFileNameFormat("Iso8601WithTimeZone", "ISO8601 With TimeZone");
  static const Iso8601 = NoteFileNameFormat("Iso8601", "Iso8601");
  static const Iso8601WithTimeZoneWithoutColon = NoteFileNameFormat(
      "Iso8601WithTimeZoneWithoutColon", "ISO8601 without Colons");
  static const FromTitle = NoteFileNameFormat("FromTitle", "Title");

  static const Default = FromTitle;

  static const options = <NoteFileNameFormat>[
    FromTitle,
    Iso8601,
    Iso8601WithTimeZone,
    Iso8601WithTimeZoneWithoutColon,
  ];

  static NoteFileNameFormat fromInternalString(String str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static NoteFileNameFormat fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  final String _str;
  final String _publicStr;

  const NoteFileNameFormat(this._str, this._publicStr);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return _publicStr;
  }

  @override
  String toString() {
    assert(false, "NoteFileNameFormat toString should never be called");
    return "";
  }
}

class RemoteSyncFrequency {
  static const Automatic = RemoteSyncFrequency("Automatic");
  static const Manual = RemoteSyncFrequency("Manual");
  static const Default = Automatic;

  final String _str;
  const RemoteSyncFrequency(this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return _str;
  }

  static const options = <RemoteSyncFrequency>[
    Automatic,
    Manual,
  ];

  static RemoteSyncFrequency fromInternalString(String str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static RemoteSyncFrequency fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }
}
