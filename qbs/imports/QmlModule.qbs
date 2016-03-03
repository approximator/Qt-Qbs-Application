import qbs
import qbs.FileInfo


Product {
    type: "copied_resource"

    property string srcPrefix: "modules"
    property path targetDirectory: product.destinationDirectory

    Depends { name: "copyable_resource" }
    copyable_resource.prefix: srcPrefix
    copyable_resource.targetDirectory: targetDirectory
}
