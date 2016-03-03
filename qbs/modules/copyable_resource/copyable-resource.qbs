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
