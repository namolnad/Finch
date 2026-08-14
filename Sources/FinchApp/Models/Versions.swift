import ArgumentParser
import Version

struct Versions: ExpressibleByArgument {
    let old: Version

    let new: Version

    init?(argument: String) {
        guard let versions = try? VersionsResolver().versions(from: argument) else {
            return nil
        }

        self.init(old: versions.old, new: versions.new)
    }

    init(old: Version, new: Version) {
        self.old = old
        self.new = new
    }
}
