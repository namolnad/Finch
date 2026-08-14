/**
 * Type-safe template which determines the final format for
 * the per-line output for a given section. Initialized via
 * a `format_string` at the global or section level in the
 * configuration file.
 */
public struct FormatTemplate {
    /// :nodoc:
    let outputtables: [LineOutputtable]
}

extension FormatTemplate {
    /// :nodoc:
    init?(formatString: String?) {
        guard let outputtables = formatString?.lineOutputtables, !outputtables.isEmpty else {
            return nil
        }

        self.init(outputtables: outputtables)
    }

    /**
     * FormatTemplate if no section-specific or global `format_string` has
     * been configured. Equivalent to the format_string value of:
     * `" - << tags >> << message >> — << commit_type_hyperlink >> — << contributor_handle >>"`
     */
    static let `default`: FormatTemplate = .init(
        outputtables: [
            " - ",
            FormatComponent.tags,
            " ",
            FormatComponent.message,
            " - ",
            FormatComponent.commitTypeHyperlink,
            " - ",
            FormatComponent.contributorHandle
        ]
    )

    /// :nodoc:
    var formatString: String {
        outputtables.reduce("") { (partial: String, outputtable: LineOutputtable) in
            switch outputtable {
            case let component as FormatComponent:
                partial + "<< \(component.rawValue) >>"
            case let string as String:
                partial + string
            default:
                partial
            }
        }
    }
}

extension String {
    /// Walk along format string to gather typed LineOutputtable's
    fileprivate var lineOutputtables: [LineOutputtable] {
        var components: [String] = []
        var component = ""
        if let value = first {
            component.append(value)
        }

        func flush() {
            guard !component.isEmpty else { return }
            components.append(component)
            component = ""
        }

        func string(for formatComponent: FormatComponent) -> String {
            formatComponent.rawValue
        }

        func format(component: FormatComponent) -> LineOutputtable {
            component
        }

        for idx in indices.dropFirst().dropLast() {
            let nextEqualToCurrent = self[index(after: idx)] == self[idx]
            let currentEqualToPrev = self[index(before: idx)] == self[idx]
            let currentIsOpening = self[idx] == "<"
            let currentIsClosing = self[idx] == ">"

            if nextEqualToCurrent, currentIsOpening {
                flush()
            }

            component.append(self[idx])

            if currentEqualToPrev, currentIsClosing {
                flush()
            }
        }

        // Clean up last closing
        if !component.isEmpty {
            component.append(self[index(before: endIndex)])
            flush()
        }

        var transformedComps: [LineOutputtable] = []

        for component in components {
            let outputtable: LineOutputtable = switch component {
            case "<< \(string(for: .commitTypeHyperlink)) >>":
                format(component: .commitTypeHyperlink)
            case "<< \(string(for: .contributorEmail)) >>":
                format(component: .contributorEmail)
            case "<< \(string(for: .contributorHandle)) >>":
                format(component: .contributorHandle)
            case "<< \(string(for: .message)) >>":
                format(component: .message)
            case "<< \(string(for: .tags)) >>":
                format(component: .tags)
            case "<< \(string(for: .sha)) >>":
                format(component: .sha)
            default:
                component
            }

            transformedComps.append(outputtable)
        }

        return transformedComps
    }
}
