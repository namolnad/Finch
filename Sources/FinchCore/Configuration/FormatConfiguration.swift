/**
 * Sub-configuration for the formatting of the overall output as well
 * as the input for tag delimiters.
 */
public struct FormatConfiguration {
    /**
     * Sub-configuration for the project's tag delimiters.
     */
    public private(set) var delimiterConfig: DelimiterConfiguration

    /**
     * A custom footer string.
     */
    public private(set) var footer: String?

    /**
     * A global format template to replace the built-in default.
     * Initialized via a `format_string` key in the configuration file.
     */
    public private(set) var formatTemplate: FormatTemplate?

    /**
     * A custom header string.
     */
    public private(set) var header: String?

    public private(set) var markup: Markup

    /**
     * A list of SectionInfo structures for the project. Sections
     * will appear in the final output in the same order they are
     * listed in the configuration file.
     */
    public private(set) var sectionInfos: [SectionInfo]
}

/// :nodoc:
extension FormatConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case delimiterConfig = "delimiters"
        case footer
        case formatString = "format_string"
        case header
        case markup
        case sectionInfos = "section_infos"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let formatString: String? = container.optionalDecode(forKey: .formatString)
        self.delimiterConfig = container.decode(forKey: .delimiterConfig, default: .blank)
        self.footer = container.optionalDecode(forKey: .footer)
        self.formatTemplate = FormatTemplate(formatString: formatString)
        self.header = container.optionalDecode(forKey: .header)
        self.markup = container.decode(forKey: .markup, default: .markdown)
        self.sectionInfos = container.decode(forKey: .sectionInfos, default: [])
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(delimiterConfig, forKey: .delimiterConfig)
        try container.encode(footer, forKey: .footer)
        try container.encode(formatTemplate?.formatString, forKey: .formatString)
        try container.encode(header, forKey: .header)
        try container.encode(markup, forKey: .markup)
        try container.encode(sectionInfos, forKey: .sectionInfos)
    }
}

/// :nodoc:
extension FormatConfiguration: SubConfiguration {
    public static var blank: FormatConfiguration = .init(
        delimiterConfig: .blank,
        footer: nil,
        formatTemplate: nil,
        header: nil,
        markup: .markdown, // TODO: determine if this breaks config - don't think it should based on cursory look
        sectionInfos: []
    )

    public static var `default`: FormatConfiguration = .init(
        delimiterConfig: .default,
        footer: nil,
        formatTemplate: .default,
        header: nil,
        markup: .markdown,
        sectionInfos: .default
    )
}

/// :nodoc:
extension FormatConfiguration: Mergeable {
    public func merge(into other: inout FormatConfiguration) {
        if !sectionInfos.isEmpty, sectionInfos.allSatisfy({ !$0.isDefault }) {
            other.sectionInfos = sectionInfos
        }

        if let formatTemplate = formatTemplate {
            other.formatTemplate = formatTemplate
        }

        if let header = header {
            other.header = header
        }

        if let footer = footer {
            other.footer = footer
        }

        other.markup = markup

        delimiterConfig.merge(into: &other.delimiterConfig)
    }
}

extension FormatConfiguration {
    public enum Markup: String, Codable {
        case html
        case markdown
    }
}
