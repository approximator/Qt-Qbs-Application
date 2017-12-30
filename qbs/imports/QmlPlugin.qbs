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

    Group {
        name: "qml_plugin_install"
        fileTagsFilter: [ "dynamiclibrary", "qml_import" ]
        fileTags: ["qml_import"]
        qbs.install: true
        qbs.installPrefix: bundleInstallDir
    }
}
