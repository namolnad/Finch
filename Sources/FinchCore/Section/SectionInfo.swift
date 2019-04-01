//
//  SectionInfo.swift
//  FinchCore
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import FinchUtilities

/**
 * A structure to describe the meta-contents of a section. Used for
 * section description, formatting, and commit-to-section assignment.
 */
public struct SectionInfo {
    /**
     * If true, normalizes each commit message by capitalizing the first
     * letter of the message.
     * > Defaults to `false`
     */
    public let capitalizesMessage: Bool

    /**
     * If `true`, section is excluded from the final output.
     * Useful if a wildcard section exists, but certain tags which would
     * otherwise be captured by the wildcard are desired to be excluded
     * from the final output.
     * > Defaults to `false`
     */
    public let excluded: Bool

    /**
     * Optional template created if a `format_string` is included in the
     * section's configuration.
     */
    public let formatTemplate: FormatTemplate?

    /**
     * The tags which are owned by the section. Each matching commit
     * will be placed into its owning section.
     *
     * ### Behavior
     *
     * - Greedy
     *    - If included sections have duplicative tags, the last section
     * with a given tag wins
     *
     * - Exclusive
     *    - Commits will only appear in a single section\
     * - Searching
     *    - As Finch iterates over each commit, it searches first
     * for a section matching the first commit tag, then the second and so on.
     *
     * - Wildcard
     *    - One wildcard section can be included.
     * Do so by including a `*` in the section's tag config
     */
    public let tags: [String]

    /**
     * The section's unique title.
     */
    public let title: String
}

/// :nodoc:
extension SectionInfo: Codable {
    enum CodingKeys: String, CodingKey {
        case capitalizesMessage = "capitalizes_message"
        case excluded
        case formatString = "format_string"
        case tags
        case title
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let formatString: String? = container.optionalDecode(forKey: .formatString)
        self.capitalizesMessage = container.decode(forKey: .capitalizesMessage, default: false)
        self.excluded = container.decode(forKey: .excluded, default: false)
        self.formatTemplate = FormatTemplate(formatString: formatString)
        self.tags = try container.decode(forKey: .tags)
        self.title = try container.decode(forKey: .title)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(formatTemplate?.formatString, forKey: .formatString)
        try container.encode(capitalizesMessage, forKey: .capitalizesMessage)
        try container.encode(excluded, forKey: .excluded)
        try container.encode(tags, forKey: .tags)
        try container.encode(title, forKey: .title)
    }
}

extension SectionInfo {
    fileprivate static let `default`: SectionInfo = .init(
        capitalizesMessage: false,
        excluded: false,
        formatTemplate: .default,
        tags: ["*"],
        title: "Features"
    )

    fileprivate static let bugs: SectionInfo = .init(
        capitalizesMessage: false,
        excluded: false,
        formatTemplate: .default,
        tags: ["bugfix", "bug fix", "bug"],
        title: "Bug Fixes"
    )
}

extension SectionInfo: Equatable {}

/// :nodoc:
extension Array where Element == SectionInfo {
    static let `default`: [SectionInfo] = [
        .default,
        .bugs
    ]
}
