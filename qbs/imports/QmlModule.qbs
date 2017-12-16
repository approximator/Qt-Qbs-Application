/*
 * Copyright © 2015-2016 Andrii Shelest. All rights reserved.
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


Product {
    name: "qml_module"
    type: "qml_import"

    Depends { name: "app_config" }

    property string moduleSourcesDir: "modules"
    property path moduleBaseDir: FileInfo.joinPaths(sourceDirectory, moduleSourcesDir)
    property path moduleInstallDir: app_config.qmlInstallDir

    property pathList qmlImportPaths: [ moduleBaseDir ]

    Group {
        name: "qml_install"
        fileTagsFilter: ["qml_import"]

        qbs.install: true
        qbs.installSourceBase: moduleBaseDir
        qbs.installPrefix: moduleInstallDir
    }
}
