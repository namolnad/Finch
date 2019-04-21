import SwiftCLI
import Version

struct Versions: ConvertibleFromString {
    let old: Version

    let new: Version

    static var null: Versions = .init(old: .null, new: .null)

    public static var name: String = "versions"

    public static func convert(from: String) -> Versions? {
        guard let versions = try? VersionsResolver().versions(from: from) else {
            return nil
        }

        return Versions(old: versions.old, new: versions.new)
    }
}
