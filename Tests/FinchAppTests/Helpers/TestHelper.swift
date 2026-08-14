import Foundation
import Yams

final class TestHelper {
    static var isMacOS: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }

    private let decoder: YAMLDecoder = .init()

    private static let instance: TestHelper = .init()

    private init() {}

    static func model<T: Decodable>(for path: String) -> T {
        let encodedYaml = String(data: data(for: path), encoding: .utf8)!
        return try! instance.decoder.decode(from: encodedYaml)
    }

    static func data(for path: String) -> Data {
        guard let url = Bundle.module.url(forResource: path, withExtension: "yml") else {
            fatalError("Missing test resource: \(path).yml")
        }

        return try! Data(contentsOf: url)
    }
}
