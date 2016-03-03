/*
 * Copyright © 2015-2016 Andrii Shelest. All rights reserved.
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

Project {
    name: "QtQmlApp"
    minimumQbsVersion: "1.4"

    property variant appVersion: {
        major: 0;
        minor: 0;
        release: 1
    }
    property string appVersionString: {return "hello"}

    property string appName: name
    property string appShortName: appName

    property path appSourceRoot: sourceDirectory
    property path appInstallRoot: qbs.installRoot
    property path appInstallDir: qbs.targetOS.contains("osx")
                                   ? appName + ".app/Contents"
                                   : appName

    property path appAppTarget: qbs.targetOS.contains("osx")
                                 ? appName
                                 : appShortName
    property path appDataPath: qbs.targetOS.contains("osx")
                                   ? "Resources"
                                   : "data"

    property path appBinDir: qbs.targetOS.contains("osx")
                                  ? appInstallDir + "/MacOS"
                                  : ""
    property path appQmlInstallDir: FileInfo.joinPaths(appDataPath, "qml")
    property path appConfigSourceRoot: FileInfo.joinPaths(appSourceRoot, "doc/config/")
    property path appConfigInstallDir: FileInfo.joinPaths(appDataPath, "config")
    property path appPluginsInstallDir: FileInfo.joinPaths(appDataPath, "plugins")

    property bool fgapSubmodulesReady: false

    property stringList generalDefines: [
        'APP_QML_MODULES_PATH="' + FileInfo.relativePath (appBinDir, appQmlInstallDir) + '"',
        'APP_PLUGINS_PATH="' + FileInfo.relativePath (appBinDir, appPluginsInstallDir) + '"',
        'APP_CONFIG_PATH="' + FileInfo.relativePath (appBinDir, appConfigInstallDir) + '"'
    ]

    property stringList generalCppFlags: []
}
