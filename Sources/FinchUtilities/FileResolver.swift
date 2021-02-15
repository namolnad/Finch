import Foundation
import Yams

public final class FileResolver<FileType: Decodable> {
    private lazy var decoder: YAMLDecoder = .init()

    private let fileManager: FileManager

    private let pathComponent: String

    public init(fileManager: FileManager, pathComponent: String = "") {
        self.fileManager = fileManager
        self.pathComponent = pathComponent
    }

    public func resolve(path: String) throws -> FileType? {
        guard
            case let filePath = path + pathComponent,
            let data = fileManager.contents(atPath: filePath),
            let encodedYaml = String(data: data, encoding: .utf8)
        else { return nil }

        return try decoder.decode(from: encodedYaml)
    }
}
