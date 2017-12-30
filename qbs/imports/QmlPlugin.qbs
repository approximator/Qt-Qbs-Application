import qbs
import qbs.FileInfo

DynamicLibrary {
    name: "qml_plugin"

    property string moduleUri: "QtQuick.plugin"
    readonly property string moduleInstallDir: FileInfo.joinPaths.apply(this, moduleUri.split("."))
    readonly property string bundleInstallDir: FileInfo.joinPaths(app_config.qmlInstallDir, moduleInstallDir)

    targetName: moduleUri.replace(".", "").toLowerCase()
    consoleApplication: true

    Depends { name: "Qt"; submodules: ["core", "qml", "quick"]}
    Qt.core.pluginMetaData: ["uri=" + moduleUri]

    Depends { name: "app_config" }

    Properties {
        condition: qbs.targetOS.contains("macos")
        cpp.sonamePrefix: "@rpath/" + bundleInstallDir
    }

    Group {
        name: "qml_plugin_install"
        fileTagsFilter: [ "dynamiclibrary", "qml_import" ]
        fileTags: ["qml_import"]
        qbs.install: true
        qbs.installPrefix: bundleInstallDir
    }
}
