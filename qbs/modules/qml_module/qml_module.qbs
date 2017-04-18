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
import qbs.File
import qbs.FileInfo

Module {
    additionalProductTypes: ["deployed_qml_resource"]
    property path targetDirectory: product.destinationDirectory
    alwaysRun: true

    Rule {
        inputs: ["qml_import"]
        outputFileTags: ["deployed_qml_resource"]

        Artifact {
            fileTags: ["deployed_qml_resource"]
            filePath: {
                var destinationDir = product.moduleProperty("qml_module", "targetDirectory");
                var output;
                for (var i in product.qmlImportPaths)
                    if(input.filePath.startsWith(product.qmlImportPaths[i])) {
                        var relPath = FileInfo.relativePath(product.qmlImportPaths[i], input.filePath)
                        output = FileInfo.joinPaths(destinationDir, relPath)
                    }
                return output;
            }
        }

        prepare: {
            var cmd = new JavaScriptCommand();
            cmd.description = "Copying " + FileInfo.fileName(input.fileName) + " -> " + output.filePath;
            cmd.highlight = "codegen";
            cmd.sourceCode = function() {
                File.makePath(FileInfo.path(output.filePath));
                File.copy(input.filePath, output.filePath);
            };
            return cmd;
        }
    }
}
