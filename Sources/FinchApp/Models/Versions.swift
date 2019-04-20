import Commandant
import Version

struct Versions: ArgumentProtocol {
    let old: Version

    let new: Version

    static var null: Versions = .init(old: .null, new: .null)

    public static var name: String = "versions"

    public static func from(string: String) -> Versions? {
        guard let versions = try? VersionsResolver().versions(from: string) else {
            return nil
        }

        return Versions(old: versions.old, new: versions.new)
    }
}
