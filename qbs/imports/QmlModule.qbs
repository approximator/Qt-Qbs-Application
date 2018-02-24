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
    Depends { name: "imports_installer" }

    property string moduleName: "QmlModule"
    readonly property path moduleSourcesDir: FileInfo.joinPaths(sourceDirectory, moduleName)
    property path moduleBaseDir: sourceDirectory

    property pathList qmlImportPaths: [ moduleBaseDir ]

    imports_installer.baseDir: sourceDirectory
    imports_installer.installDir: FileInfo.joinPaths(qbs.installRoot, app_config.qmlInstallDir)
}

