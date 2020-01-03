import SwiftCLI
import Version

struct Versions {
    let old: Version

    let new: Version

    static var null: Versions = .init(old: .null, new: .null)

    public static var name: String = "versions"
}

extension Versions: ConvertibleFromString {
    init?(input: String) {
        guard let versions = try? VersionsResolver().versions(from: input) else {
            return nil
        }

        self = .init(old: versions.old, new: versions.new)
    }
}
