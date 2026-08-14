import Foundation

public protocol OutputType {
    func print(_ value: String, kind: Output.Kind, verbose: Bool)
}

public struct Output: OutputType, Sendable {
    public enum Kind: Sendable {
        case `default`
        case error
        case info
    }

    public static let instance: Output = .init()

    /**
     * Built per timestamp rather than stored: DateFormatter is a reference
     * type, and holding one would keep `Output` — and so the shared instance
     * above — off Sendable. Only verbose output is stamped, so the cost is
     * paid rarely.
     */
    private var timeStamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"

        return formatter.string(from: Date())
    }

    private init() {}

    public func print(_ value: String, kind: Kind, verbose: Bool = false) {
        switch kind {
        case .default:
            Swift.print(value)
        case .error:
            // Written through FileHandle rather than fputs: on Glibc `stderr`
            // is a mutable global, which Swift 6 refuses to touch
            FileHandle.standardError.write(Data("🚨 \(value)\n".utf8))

            exit(EXIT_FAILURE)
        case .info:
            guard verbose else {
                return
            }

            Swift.print("[\(timeStamp)]: \(value)")
        }
    }
}
