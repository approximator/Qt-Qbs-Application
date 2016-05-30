/*
 * Copyright © 2015-2016 Oleksii Aliakin. All rights reserved.
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
import "qmlTools.js" as Tools

QtGuiApplication {
    property string appShortName: name
    property string appName: name
    targetName: appShortName

    property bool install: true
    property path installDir: appName
    property path appSourceRoot: sourceDirectory
    property pathList qmlImportsPaths

    property path appBinDir
    property path appContentsPath
    property path appDataPath: FileInfo.joinPaths(appContentsPath, "data")

    property path appQmlInstallDir: FileInfo.joinPaths(appContentsPath, "qml")
    property path appConfigSourceRoot: FileInfo.joinPaths(appSourceRoot, "doc", "config")
    property path appConfigInstallDir: FileInfo.joinPaths(appContentsPath, "config")
    property path appPluginsInstallDir: FileInfo.joinPaths(appDataPath, "plugins")

    Properties {
        condition: bundle.isBundle
        targetName: appName
        installDir: "Applications"
        appBinDir: bundle.executableFolderPath
        appContentsPath: bundle.contentsFolderPath
        appDataPath: FileInfo.joinPaths(appContentsPath, "Resources/data")

        appQmlInstallDir: FileInfo.joinPaths(appContentsPath, "Imports/qtquick2")
        appConfigSourceRoot: FileInfo.joinPaths(appSourceRoot, "doc/config")
        appConfigInstallDir: FileInfo.joinPaths(appContentsPath, "Resources/config")
        appPluginsInstallDir: FileInfo.joinPaths(appDataPath, "Plugins")
    }

    property string cppVersion: "c++11"
    property stringList generalDefines: [
        'APP_QML_MODULES_PATH="' + Tools.getRelativePath(appBinDir, appQmlInstallDir) + '"',
        'APP_PLUGINS_PATH="' + Tools.getRelativePath(appBinDir, appPluginsInstallDir) + '"',
        'APP_CONFIG_PATH="' + Tools.getRelativePath(appBinDir, appConfigInstallDir) + '"'
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

    cpp.defines: generalDefines
    cpp.rpaths: qbs.targetOS.contains("osx")
                ? ["@executable_path/../Frameworks"]
                : ["$ORIGIN/", "$ORIGIN/../lib", "$ORIGIN/lib"]

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
        qbs.installDir: bundle.isBundle ? FileInfo.joinPaths(installDir, appBinDir) : installDir
    }

    Group {
        fileTagsFilter: ["aggregate_infoplist"]
        qbs.install: install && bundle.isBundle
                     && !bundle.embedInfoPlist
        qbs.installDir: FileInfo.joinPaths(installDir, FileInfo.path(bundle.infoPlistPath))
    }

    Group {
        fileTagsFilter: ["pkginfo"]
        qbs.install: install && bundle.isBundle
        qbs.installDir: FileInfo.joinPaths(installDir, FileInfo.path(bundle.pkgInfoPath))
    }

    Group {
        fileTagsFilter: ["jsonConfigs"]
        qbs.install: true
        qbs.installDir: FileInfo.joinPaths(installDir, appConfigInstallDir)
    }

    Group {
        condition: qmlImportsPaths !== undefined
        name: "QmlImports"
        fileTags: ["qml_import"]
        files: qmlImportsPaths.map(function(path) { return path + "/**/" })
    }

    Depends{ name: "qml_module" }
    qml_module.targetDirectory: FileInfo.joinPaths(qbs.installRoot,
                                                   installDir,
                                                   product.appQmlInstallDir)

    /* Some debug output */
    property string debug: {
        print("Cpp version: " + cpp.cxxLanguageVersion)
        print("System include paths:")
        cpp.systemIncludePaths.forEach(function(path) {
            print("    " + path);
        })

        print("Install to: " + qbs.installRoot)
    }

}
