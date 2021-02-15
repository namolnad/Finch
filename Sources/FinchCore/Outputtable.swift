/// :nodoc:
public protocol Outputtable {
    var output: String { get }
}

/// :nodoc:
extension Array: Outputtable where Element: Outputtable {
    public var output: String {
        map(\.output)
            .joined(separator: "\n")
    }
}
