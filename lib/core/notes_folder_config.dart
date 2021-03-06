import 'dart:io';

import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/core/sorting_mode.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/folder_views/standard_view.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/logger.dart';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'package:yaml/yaml.dart';
import 'package:yaml_serializer/yaml_serializer.dart';
import 'package:equatable/equatable.dart';

@immutable
class NotesFolderConfig extends Equatable {
  static const FILENAME = ".gitjournal.yaml";

  final SortingMode sortingMode;
  final EditorType defaultEditor;
  final FolderViewType defaultView;

  final StandardViewHeader viewHeader;
  final bool showNoteSummary;
  final NoteFileNameFormat fileNameFormat;
  final NotesFolderFS folder;
  //int _version = 1;

  NotesFolderConfig({
    @required this.sortingMode,
    @required this.defaultEditor,
    @required this.defaultView,
    @required this.viewHeader,
    @required this.showNoteSummary,
    @required this.fileNameFormat,
    @required this.folder,
  });

  @override
  List<Object> get props => [
        sortingMode,
        defaultEditor,
        defaultView,
        viewHeader,
        fileNameFormat,
        folder,
      ];

  static NotesFolderConfig fromSettings(NotesFolderFS folder) {
    var settings = Settings.instance;

    StandardViewHeader viewHeader;
    switch (settings.folderViewHeaderType) {
      case "TitleGenerated":
        viewHeader = StandardViewHeader.TitleGenerated;
        break;
      case "FileName":
        viewHeader = StandardViewHeader.FileName;
        break;
      case "TitleOrFileName":
        viewHeader = StandardViewHeader.TitleOrFileName;
        break;
    }

    return NotesFolderConfig(
      defaultEditor: settings.defaultEditor.toEditorType(),
      defaultView: settings.defaultView.toFolderViewType(),
      sortingMode: settings.sortingMode,
      showNoteSummary: settings.showNoteSummary,
      viewHeader: viewHeader,
      fileNameFormat: settings.noteFileNameFormat,
      folder: folder,
    );
  }

  Future<void> saveToSettings() async {
    Settings.instance.sortingMode = sortingMode;
    Settings.instance.showNoteSummary = showNoteSummary;
    Settings.instance.defaultEditor =
        SettingsEditorType.fromEditorType(defaultEditor);
    Settings.instance.defaultView =
        SettingsFolderViewType.fromFolderViewType(defaultView);

    String ht;
    switch (viewHeader) {
      case StandardViewHeader.FileName:
        ht = "FileName";
        break;
      case StandardViewHeader.TitleGenerated:
        ht = "TitleGenerated";
        break;
      case StandardViewHeader.TitleOrFileName:
        ht = "TitleOrFileName";
        break;
    }
    Settings.instance.folderViewHeaderType = ht;
    Settings.instance.noteFileNameFormat = fileNameFormat;
    Settings.instance.save();
  }

  NotesFolderConfig copyWith({
    SortingMode sortingMode,
    EditorType defaultEditor,
    FolderViewType defaultView,
    StandardViewHeader viewHeader,
    bool showNoteSummary,
    NoteFileNameFormat fileNameFormat,
    NotesFolderFS folder,
  }) {
    return NotesFolderConfig(
      sortingMode: sortingMode ?? this.sortingMode,
      defaultEditor: defaultEditor ?? this.defaultEditor,
      defaultView: defaultView ?? this.defaultView,
      viewHeader: viewHeader ?? this.viewHeader,
      showNoteSummary: showNoteSummary ?? this.showNoteSummary,
      fileNameFormat: fileNameFormat ?? this.fileNameFormat,
      folder: folder ?? this.folder,
    );
  }

  static Future<NotesFolderConfig> fromFS(NotesFolderFS folder) async {
    var file = File(p.join(folder.folderPath, FILENAME));
    if (!file.existsSync()) {
      return null;
    }

    var map = <String, dynamic>{};
    var contents = await file.readAsString();
    try {
      var yamlMap = loadYaml(contents);
      yamlMap.forEach((key, value) {
        map[key] = value;
      });
    } catch (err) {
      Log.d('NotesFolderConfig::decode("$contents") -> ${err.toString()}');
    }

    var sortingMode =
        SortingMode.fromInternalString(map["sortingMode"]?.toString());
    var defaultEditor =
        SettingsEditorType.fromInternalString(map["defaultEditor"]?.toString());
    var defaultView = SettingsFolderViewType.fromInternalString(
        map["defaultView"]?.toString());

    var showNoteSummary = map["showNoteSummary"].toString() != "false";

    var folderViewHeaderType = map["folderViewHeaderType"]?.toString();
    StandardViewHeader viewHeader;
    switch (folderViewHeaderType) {
      case "TitleGenerated":
        viewHeader = StandardViewHeader.TitleGenerated;
        break;
      case "FileName":
        viewHeader = StandardViewHeader.FileName;
        break;
      case "TitleOrFileName":
        viewHeader = StandardViewHeader.TitleOrFileName;
        break;
    }

    var fileNameFormat = map['noteFileNameFormat']?.toString();

    return NotesFolderConfig(
      defaultEditor: defaultEditor.toEditorType(),
      defaultView: defaultView.toFolderViewType(),
      sortingMode: sortingMode,
      showNoteSummary: showNoteSummary,
      viewHeader: viewHeader,
      fileNameFormat: NoteFileNameFormat.fromInternalString(fileNameFormat),
      folder: folder,
    );
  }

  Future<void> saveToFS() async {
    String ht;
    switch (viewHeader) {
      case StandardViewHeader.FileName:
        ht = "FileName";
        break;
      case StandardViewHeader.TitleGenerated:
        ht = "TitleGenerated";
        break;
      case StandardViewHeader.TitleOrFileName:
        ht = "TitleOrFileName";
        break;
    }

    var map = <String, dynamic>{
      "sortingMode": sortingMode.toInternalString(),
      "defaultEditor":
          SettingsEditorType.fromEditorType(defaultEditor).toInternalString(),
      "defaultView": SettingsFolderViewType.fromFolderViewType(defaultView)
          .toInternalString(),
      "showNoteSummary": showNoteSummary,
      "folderViewHeaderType": ht,
      "noteFileNameFormat": fileNameFormat.toInternalString(),
    };

    var yaml = toYAML(map);

    var file = File(p.join(folder.folderPath, FILENAME));
    await file.writeAsString(yaml);
  }
}
