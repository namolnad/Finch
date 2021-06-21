/// :nodoc:
public struct Line {
    let value: String
}

/// :nodoc:
extension Line {
    static func from(components: LineComponents, context: LineContext) -> Line {
        let template: FormatTemplate = context.sectionInfo.formatTemplate ??
            context.configuration.formatConfig.formatTemplate ??
            .default

        let value = template.outputtables.reduce("") { partial, next in
            let nextOut = next.output(components: components, context: context)
            if partial.hasSuffix(" "), nextOut.hasPrefix(" ") {
                return partial + String(nextOut.dropFirst())
            } else {
                return partial + nextOut
            }
        }

        return .init(value: value.trimmingCharacters(in: .whitespaces))
    }
}

/// :nodoc:
extension Line: Outputtable {
    public func output(markup: FormatConfiguration.Markup) -> String {
        switch markup {
        case .html:
            return "<li>\(value)</li>" // FIXME: figure out what the actual markup is
        case .markdown:
            return " - \(value)"
        }
    }
}
