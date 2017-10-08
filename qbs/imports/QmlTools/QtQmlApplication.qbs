/*
 * Copyright © 2015-2017 Oleksii Aliakin. All rights reserved.
 * Author: Oleksii Aliakin (alex@nls.la)
 * Author: Andrii Shelest
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import qbs
import qbs.FileInfo

QtGuiApplication {
    property string appName: name
    property string appShortName: appName
    targetName: appShortName

    property bool install: true
    property path appInstallDir: appName
    property path appSourceRoot: sourceDirectory
    property pathList qmlImportPaths: []

    property path appBinDir: FileInfo.joinPaths(qbs.installRoot, appName)
    property path appContentsPath: FileInfo.joinPaths(qbs.installRoot, appName)
    property path appDataPath: FileInfo.joinPaths(appContentsPath, "data")

    property path appQmlInstallDir: FileInfo.joinPaths(appDataPath, "qml")
    property path appConfigSourceRoot: FileInfo.joinPaths(appSourceRoot, "..", "doc", "config", "/")
    property path appConfigInstallDir: FileInfo.joinPaths(appDataPath, "config")
    property path appPluginsInstallDir: FileInfo.joinPaths(appDataPath, "plugins")
    property path appLibsInstallDir: FileInfo.joinPaths(appContentsPath, "lib")
    property path appIncludesInstallDir: FileInfo.joinPaths(appDataPath, "include")

    Properties {
        condition: bundle.isBundle
        targetName: appName
        appInstallDir: "Applications"
        appBinDir: bundle.executableFolderPath
        appContentsPath: bundle.contentsFolderPath
        appDataPath: FileInfo.joinPaths(appContentsPath, "Resources/data")

        appQmlInstallDir: FileInfo.joinPaths(appContentsPath, "Imports/qtquick2")
        appConfigSourceRoot: FileInfo.joinPaths(appSourceRoot, "doc/config")
        appConfigInstallDir: FileInfo.joinPaths(appContentsPath, "Resources/config")
        appPluginsInstallDir: FileInfo.joinPaths(appDataPath, "Plugins")
        appLibsInstallDir: FileInfo.joinPaths(appDataPath, "Frameworks")
        appIncludesInstallDir: FileInfo.joinPaths(appDataPath, "Include")
    }

    property string cppVersion: "c++11"
    property stringList generalDefines: []
    property stringList appDefines: [
        'APP_QML_MODULES_PATH="' + FileInfo.relativePath(appBinDir, appQmlInstallDir) + '"',
        'APP_PLUGINS_PATH="' + FileInfo.relativePath(appBinDir, appPluginsInstallDir) + '"',
        'APP_CONFIG_PATH="' + FileInfo.relativePath(appBinDir, appConfigInstallDir) + '"'
    ]

    property bool extraWarnings: false

    Depends { name: "cpp" }
    cpp.cxxLanguageVersion: cppVersion
    cpp.warningLevel: extraWarnings ? "all" : "none"

    Properties {
        condition: qbs.targetOS.contains("linux") && extraWarnings
        cpp.commonCompilerFlags: ['-Wall', '-Wextra', '-pedantic', '-Weffc++', '-Wold-style-cast']
        cpp.systemIncludePaths: [
            FileInfo.joinPaths(Qt.core.incPath),
            FileInfo.joinPaths(Qt.core.incPath, 'QtCore'),
            FileInfo.joinPaths(Qt.core.incPath, 'QtGui'),
            FileInfo.joinPaths(Qt.core.incPath, 'QtQml'),
            FileInfo.joinPaths(Qt.core.incPath, 'QtSvg'),
        ]
    }

    cpp.defines: appDefines.concat(generalDefines)
    cpp.rpaths: qbs.targetOS.contains("osx")
                ? ["@executable_path/" + FileInfo.relativePath(appBinDir, appLibsInstallDir)]
                : ["$ORIGIN/", "$ORIGIN/" + FileInfo.relativePath(appBinDir, appLibsInstallDir)]

    Properties {
        //Clang special configs
        condition: qbs.toolchain.contains("clang")
        cpp.cxxStandardLibrary: {
            if(qbs.targetOS.contains("osx"))
                return "libc++"
            else if(qbs.targetOS.contains("linux"))
                return "libstdc++"
            else
                return undefined
        }
    }

    Group {
        fileTagsFilter: ["application"]
        qbs.install: install
        qbs.installDir: bundle.isBundle ? appBinDir : product.appInstallDir
    }

    Group {
        fileTagsFilter: ["public_headers"]
        qbs.install: install
        qbs.installDir: FileInfo.joinPaths(product.appInstallDir, appIncludesInstallDir)
    }

    Group {
        fileTagsFilter: ["aggregate_infoplist"]
        qbs.install: install && bundle.isBundle
                     && !bundle.embedInfoPlist
        qbs.installDir: FileInfo.joinPaths(product.appInstallDir, FileInfo.path(bundle.infoPlistPath))
    }

    Group {
        fileTagsFilter: ["pkginfo"]
        qbs.install: install && bundle.isBundle
        qbs.installDir: FileInfo.joinPaths(product.appInstallDir, FileInfo.path(bundle.pkgInfoPath))
    }

    Group {
        fileTagsFilter: ["jsonConfigs"]
        qbs.install: install
        qbs.installDir: FileInfo.joinPaths(product.appInstallDir, appConfigInstallDir)
    }

    Group {
        condition: qmlImportPaths.length > 0
        name: "QmlImports"
        fileTags: ["qml_import"]
        files: condition ? qmlImportPaths.map(function(path) { return path + "/**/" }) : []
    }

    Depends{ name: "qml_module" }
    qml_module.targetDirectory: product.appQmlInstallDir

    /* Some debug output */
    property string debug: {
        console.info("Cpp version: " + cpp.cxxLanguageVersion)
        console.info("System include paths:")
        console.info(cpp.systemIncludePaths);
        console.info("Install to: " + qbs.installRoot)
    }
}
