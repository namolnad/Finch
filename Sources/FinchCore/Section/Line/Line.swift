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

        var parts: [String] = []

        for outputtable in template.outputtables {
            let output = outputtable.output(components: components, context: context)

            /*
             * A component which renders nothing — a commit with no tags, or
             * none of the breaking changes — would otherwise leave the
             * separator introducing it stranded. The separator opening the
             * line is kept, since that is a bullet rather than a join.
             */
            if
                output.isEmpty,
                outputtable is FormatComponent,
                let separator = parts.last,
                separator.isSeparator,
                parts.dropLast().contains(where: { !$0.isEmpty })
            {
                parts.removeLast()
            }

            parts.append(output)
        }

        let value = parts.reduce("") { partial, next in
            if partial.hasSuffix(" "), next.hasPrefix(" ") {
                partial + String(next.dropFirst())
            } else {
                partial + next
            }
        }

        return .init(value: value)
    }
}

extension String {
    /// Whether the string is only the punctuation and spacing which joins two components.
    fileprivate var isSeparator: Bool {
        !isEmpty && allSatisfy { $0.isWhitespace || $0.isPunctuation || $0.isSymbol }
    }
}

/// :nodoc:
extension Line: Outputtable {
    public var output: String {
        value
    }
}
