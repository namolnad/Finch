import Foundation

extension String {
    public var escaped: String {
        NSRegularExpression.escapedPattern(for: self)
    }
}
