import Foundation

struct Resource {
    /// Bundle.init(for:) is not yet implemented in swift-corelibs-foundation
    private var bundle: Bundle? {
        guard TestHelper.isMacOS else {
            return nil
        }

        return Bundle(for: TestHelper.self)
    }

    private let name: String

    private let type: String

    init(name: String, type: String) {
        self.name = name
        self.type = type
    }

    var path: String {
        guard let path = bundle?.path(forResource: name, ofType: type.isEmpty ? nil : type) else {
            let url = URL(fileURLWithPath: #file)
                .deletingLastPathComponent()
                .appendingPathComponent("../Resources")
                .appendingPathComponent(name)

            if !type.isEmpty {
                return url.appendingPathExtension(type).path
            }

            return url.path
        }

        return path
    }
}
