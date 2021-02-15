import Foundation

extension FileManager {
    static let mock: FileManager = FileManagerMock()
}

final class FileManagerMock: FileManager {
    override var currentDirectoryPath: String {
        "current"
    }

    private let customConfigPath: String?

    init(customConfigPath: String? = nil) {
        self.customConfigPath = customConfigPath
    }

    override func contents(atPath path: String) -> Data? {
        let firstPathComponent = path.components(separatedBy: "/").first!

        switch firstPathComponent {
        case currentDirectoryPath:
            return nil
        case customConfigPath:
            return TestHelper.data(for: firstPathComponent)
        default:
            return TestHelper.data(for: "default_config")
        }
    }
}
