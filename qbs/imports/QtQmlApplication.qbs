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
    property string appName: name
    property string appShortName: appName

    property bool extraWarnings: false

    targetName: appShortName

    Depends { name: "cpp" }
    Depends { name: "Qt.qml"}
    Depends { name: "Qt.quick"}
    Depends { name: "Qt.quickcontrols2"}

    Depends { name: "app_config" }
    Depends { name: "qml_imports"; required: false }

    property string relativeQmlModulesDir: Tools.getRelativePath(app_config.binDir, app_config.qmlInstallDir)
    property string relativePluginsDir: Tools.getRelativePath(app_config.binDir, app_config.pluginsInstallDir)
    property string relativeLibDir: Tools.getRelativePath(app_config.binDir, app_config.libInstallDir)
    property string relativeConfigDir: Tools.getRelativePath(app_config.binDir, app_config.configInstallDir)

    cpp.cxxLanguageVersion: "c++11"

    Properties {
        condition: qbs.targetOS.contains("linux") && extraWarnings
        cpp.warningLevel: "all"
        cpp.commonCompilerFlags: ['-Wall', '-Wextra', '-pedantic', '-Weffc++', '-Wold-style-cast']
        cpp.systemIncludePaths: [
            FileInfo.joinPaths(Qt.core.incPath),
            FileInfo.joinPaths(Qt.core.incPath, 'QtCore'),
            FileInfo.joinPaths(Qt.core.incPath, 'QtGui'),
            FileInfo.joinPaths(Qt.core.incPath, 'QtQml'),
            FileInfo.joinPaths(Qt.core.incPath, 'QtSvg'),
        ]
    }

    Properties {
        condition: bundle.isBundle

        targetName: appName
        bundle.resources: [ FileInfo.joinPaths(qbs.installRoot, app_config.dataDir)]

        relativeQmlModulesDir: Tools.getRelativePath(bundle.executableFolderPath,
                                                     FileInfo.joinPaths(bundle.contentsFolderPath, "Resources", app_config.qmlInstallDir))
        relativePluginsDir: Tools.getRelativePath(bundle.executableFolderPath,
                                                  FileInfo.joinPaths(bundle.contentsFolderPath, "Resources", app_config.pluginsInstallDir))
        relativeLibDir: Tools.getRelativePath(bundle.executableFolderPath,
                                              FileInfo.joinPaths(bundle.contentsFolderPath, "Resources", app_config.libInstallDir))
        relativeConfigDir: Tools.getRelativePath(bundle.executableFolderPath,
                                                 FileInfo.joinPaths(bundle.contentsFolderPath, "Resources", app_config.configInstallDir))
    }

    cpp.defines: [
        'APP_QML_MODULES_PATH="' + relativeQmlModulesDir + '"',
        'APP_PLUGINS_PATH="' + relativePluginsDir + '"',
        'APP_CONFIG_PATH="' + relativeConfigDir + '"'
    ]
    cpp.rpaths: qbs.targetOS.contains("osx")
                ? ["@executable_path/" + relativeLibDir]
                : ["$ORIGIN/", "$ORIGIN/" + relativeLibDir]

    Group {
        fileTagsFilter: ["application"]
        condition: !bundle.isBundle
        qbs.install: true
        qbs.installDir: app_config.binDir
    }

    /* Some debug output */
    property string debug: {
        console.info("Cpp version: " + cpp.cxxLanguageVersion)
        console.info("System include paths:")
        cpp.systemIncludePaths.forEach(function(path) {
            console.info("    " + path);
        })

        console.info("Install to: " + qbs.installRoot)
    }
}
