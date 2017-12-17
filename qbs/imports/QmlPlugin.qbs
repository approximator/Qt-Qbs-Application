import qbs
import qbs.FileInfo

DynamicLibrary {
    name: "qml_plugin"

    property string moduleUri: "QtQuick.plugin"
    readonly property string moduleInstallDir: FileInfo.joinPaths.apply(this, moduleUri.split("."))

    targetName: moduleUri.replace(".", "").toLowerCase()

    Depends { name: "Qt"; submodules: ["core", "qml", "quick"]}
    Qt.core.pluginMetaData: ["uri=" + moduleUri]

    Depends { name: "app_config" }

    Group {
        name: "qml_plugin_install"
        fileTagsFilter: [ "dynamiclibrary", "qml_import" ]
        fileTags: ["qml_import"]
        qbs.install: true
        qbs.installPrefix: FileInfo.joinPaths(app_config.qmlInstallDir, moduleInstallDir)
    }
}
