/// :nodoc:
public protocol Outputtable {
    func output(markup: FormatConfiguration.Markup) -> String
}

/// :nodoc:
extension Array: Outputtable where Element: Outputtable {
    public func output(markup: FormatConfiguration.Markup) -> String {
        return map { $0.output(markup: markup) }
            .joined(separator: "\n")
    }
}
