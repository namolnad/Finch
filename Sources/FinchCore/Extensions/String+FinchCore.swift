import Foundation

/// :nodoc:
extension String {
    init(range: NSRange, in body: String) {
        guard let range = Range(range, in: body) else {
            self = body
            return
        }

        self.init(body[range])
    }
}

/// :nodoc:
extension String: LineOutputtable {
    func output(components: LineComponents, context: LineContext) -> String {
        self
    }
}

/// :nodoc:
extension Array where Element == String {
    public func sorted(by pattern: Regex.Pattern) -> [String] {
        sorted {
            guard let match1 = pattern.matches(in: $0).first else {
                return false
            }
            guard let match2 = pattern.matches(in: $1).first else {
                return false
            }

            return String(range: match1.range, in: $0) > String(range: match2.range, in: $1)
        }
    }
}
