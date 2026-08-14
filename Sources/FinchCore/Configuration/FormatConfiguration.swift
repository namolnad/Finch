/**
 * Sub-configuration for the formatting of the overall output as well
 * as the input for tag delimiters.
 */
public struct FormatConfiguration: Sendable {
    /**
     * The convention the project's commit messages follow, which decides how
     * a message is split into its tags and its description.
     * > Defaults to `conventional`
     */
    public private(set) var commitStyle: CommitStyle?

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
        case commitStyle = "commit_style"
        case delimiterConfig = "delimiters"
        case footer
        case formatString = "format_string"
        case header
        case sectionInfos = "section_infos"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let formatString: String? = container.optionalDecode(forKey: .formatString)
        self.commitStyle = container.optionalDecode(forKey: .commitStyle)
        self.delimiterConfig = container.decode(forKey: .delimiterConfig, default: .blank)
        self.footer = container.optionalDecode(forKey: .footer)
        self.formatTemplate = FormatTemplate(formatString: formatString)
        self.header = container.optionalDecode(forKey: .header)
        self.sectionInfos = container.decode(forKey: .sectionInfos, default: [])
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(commitStyle, forKey: .commitStyle)
        try container.encode(delimiterConfig, forKey: .delimiterConfig)
        try container.encode(footer, forKey: .footer)
        try container.encode(formatTemplate?.formatString, forKey: .formatString)
        try container.encode(header, forKey: .header)
        try container.encode(sectionInfos, forKey: .sectionInfos)
    }
}

/// :nodoc:
extension FormatConfiguration: SubConfiguration {
    public static let blank: FormatConfiguration = .init(
        commitStyle: nil,
        delimiterConfig: .blank,
        footer: nil,
        formatTemplate: nil,
        header: nil,
        sectionInfos: []
    )

    public static let `default`: FormatConfiguration = .init(
        commitStyle: .conventional,
        delimiterConfig: .default,
        footer: nil,
        formatTemplate: .default,
        header: nil,
        sectionInfos: .default
    )
}

/// :nodoc:
extension FormatConfiguration: Mergeable {
    public func merge(into other: inout FormatConfiguration) {
        if let commitStyle {
            other.commitStyle = commitStyle
        }

        if !sectionInfos.isEmpty, sectionInfos.allSatisfy({ !$0.isDefault }) {
            other.sectionInfos = sectionInfos
        }

        if let formatTemplate {
            other.formatTemplate = formatTemplate
        }

        if let header {
            other.header = header
        }

        if let footer {
            other.footer = footer
        }

        delimiterConfig.merge(into: &other.delimiterConfig)
    }
}
