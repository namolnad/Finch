import Foundation
import Yams

enum TestHelper {
    static var isMacOS: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }

    static func model<T: Decodable>(for path: String) -> T {
        let encodedYaml = String(data: data(for: path), encoding: .utf8)!

        return try! YAMLDecoder().decode(from: encodedYaml)
    }

    static func data(for path: String) -> Data {
        guard let url = Bundle.module.url(forResource: path, withExtension: "yml") else {
            fatalError("Missing test resource: \(path).yml")
        }

        return try! Data(contentsOf: url)
    }
}
