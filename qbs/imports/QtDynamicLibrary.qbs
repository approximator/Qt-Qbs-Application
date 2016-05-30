import qbs
import qbs.FileInfo

DynamicLibrary {
    readonly property string libName: {
        var libName = name;

        if (!bundle.isBundle)
            libName = libName.toLowerCase();

        print("Library name is [ " + libName + "]");
        return libName;
    }

    targetName: libName

    property bool install: true
    property string installDir: bundle.isBundle
                                ? "Library/Frameworks"
                                : (qbs.targetOS.contains("windows") ? "" : "lib")

    Group {
        fileTagsFilter: [
            "dynamiclibrary",
            "dynamiclibrary_symlink",
            "dynamiclibrary_import"
        ]
        qbs.install: install
        qbs.installDir: bundle.isBundle
                        ? FileInfo.joinPaths(installDir, FileInfo.path(bundle.executablePath))
                        : installDir
    }

    Group {
        fileTagsFilter: ["aggregate_infoplist"]
        qbs.install: install && bundle.isBundle && !bundle.embedInfoPlist
        qbs.installDir: FileInfo.joinPaths(installDir, FileInfo.path(bundle.infoPlistPath))
    }
}
