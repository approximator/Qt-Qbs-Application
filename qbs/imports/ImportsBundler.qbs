import qbs
import qbs.File
import qbs.FileInfo
import qbs.BundleTools

Rule {
    multiplex: false
    inputsFromDependencies: ["qml_import"]

    Artifact {
         filePath: {
             var imports_dir = FileInfo.joinPaths(product.qbs.installRoot, product.app_config.qmlInstallDir);
             var sourceFilePath = FileInfo.relativePath(imports_dir, input.filePath)
             var bundleResourcesPath = BundleTools.destinationDirectoryForResource(
                       product, { baseDir: input.filePath, fileName: input.fileName });
             return FileInfo.joinPaths(bundleResourcesPath,
                                       product.app_config.qmlInstallDir,
                                       sourceFilePath)
         }
         fileTags: ["bundle.content"]
     }

    prepare: {
        var cmd = new JavaScriptCommand();
        cmd.description = "[ImportsBundler] Bundling QML import: " + output.filePath;
        cmd.sourceCode = function() {
            File.makePath(FileInfo.path(output.filePath));
            File.copy(input.filePath, output.filePath);
        };
        return cmd;
    }
}
