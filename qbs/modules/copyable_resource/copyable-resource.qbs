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
    property path targetDirectory
    property string prefix

    FileTagger {
        patterns: "*"
        fileTags: ["copyable_resource"]
    }

    Rule {
        inputs: ["copyable_resource"]

        Artifact {
            fileTags: ["copied_resource"]
            filePath: {
                var destinationDir = input.moduleProperty("copyable_resource", "targetDirectory");
                var prefix = input.moduleProperty("copyable_resource", "prefix");

                var sourcePath = FileInfo.joinPaths(product.sourceDirectory, prefix);
                var subFoldersPath = FileInfo.relativePath(sourcePath, input.filePath);

                if (!destinationDir) {
                    // If the destination directory has not been explicitly set, replicate the
                    // structure from the source directory in the build directory.
                    destinationDir = project.buildDirectory;
                }
                return FileInfo.joinPaths(destinationDir, subFoldersPath);
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
