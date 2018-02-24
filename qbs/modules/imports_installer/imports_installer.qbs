/*
 * Copyright © 2015-2018 Oleksii Aliakin. All rights reserved.
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
import qbs.File
import qbs.FileInfo

Module {
    additionalProductTypes: ["qml_import"]

    property path baseDir
    property path installDir: destinationDirectory
    property string installPrefix

    Rule {
        multiplex: false
        inputs: ["qml_source", "dynamiclibrary"]

        Artifact {
            filePath: {
                var fileInstallPrefix = product.imports_installer.installPrefix;
                if (product.imports_installer.baseDir) {
                    fileInstallPrefix = FileInfo.relativePath(product.imports_installer.baseDir,
                                                              FileInfo.path(input.filePath));
                }

                return FileInfo.joinPaths(product.imports_installer.installDir,
                                          fileInstallPrefix,
                                          input.fileName);
            }

            fileTags: ["qml_import"]
        }

        prepare: {
            var cmd = new JavaScriptCommand();
            var moduleFilePath = FileInfo.relativePath(product.imports_installer.installDir, output.filePath)
            cmd.description = "Installing QML import file: " + moduleFilePath;
            cmd.sourceCode = function() {
                File.makePath(FileInfo.path(output.filePath));
                File.copy(input.filePath, output.filePath);
            };
            return cmd;
        }
    }
}
