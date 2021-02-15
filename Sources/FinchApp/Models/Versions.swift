import SwiftCLI
import Version

struct Versions: ConvertibleFromString {
    let old: Version

    let new: Version

    static var null: Versions = .init(old: .null, new: .null)

    public static var name: String = "versions"

    public init?(input: String) {
        guard let versions = try? VersionsResolver().versions(from: input) else {
            return nil
        }

        self.init(old: versions.old, new: versions.new)
    }

    init(old: Version, new: Version) {
        self.old = old
        self.new = new
    }
}
