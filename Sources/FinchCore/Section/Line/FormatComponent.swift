//
//  Line_FormatComponent.swift
//  Finch
//
//  Created by Dan Loman on 11/23/18.
//  Copyright © 2018 DHL. All rights reserved.
//

/**
 * Enum representing special FormatString objects which indicate
 * where the component's corresponding data should be inserted in
 * the final FormatTemplate. A FormatComponent's rawValue should be
 * inserted in the format string, padded by a space, and enclosed in
 * double angle brackets. e.g. `<< commit_type_hyperlink >>`
 */
enum FormatComponent: String {
    /**
     * ### Represents
     * A markdown hyperlink with the title of either `Commit` or `PR #123`.
     * ### Example
     * \[PR #123\]\(url-to-pr\)
     */
    case commitTypeHyperlink = "commit_type_hyperlink"

    /**
     * ### Represents
     * The email address of the contributor who authored the commit.
     */
    case contributorEmail = "contributor_email"

    /**
     * ### Represents
     * The handle derived from the project's Contributor configuration file.
     * If there is no handle found, the raw email address will
     * be used in its place.
     */
    case contributorHandle = "contributor_handle"

    /**
     * ### Represents
     * The message of the current commit.
     */
    case message

    /**
     * ### Represents
     * The sha of the current commit.
     */
    case sha

    /**
     * ### Represents
     * All tags included in the current commit.
     * ### Example
     * `[tag][other] Random commit message` produces `[tag][other]`
     */
    case tags
}

extension FormatComponent: Codable {}

/// :nodoc:
extension FormatComponent: LineOutputtable {
    func output(components: LineComponents, context: LineContext) -> String {
        switch self {
        case .commitTypeHyperlink:
            var urlTitle = "Commit"
            var url = "\(context.configuration.gitConfig.repoBaseUrl)/commit/\(components.sha)"
            if let prNum = components.pullRequestNumber {
                urlTitle = "PR #\(prNum)"
                url = "\(context.configuration.gitConfig.repoBaseUrl)/pull/\(prNum)"
            }
            return "[\(urlTitle)](\(url))"
        case .contributorEmail:
            return components.contributorEmail
        case .contributorHandle:
            guard let contributor = context.configuration.contributorsConfig.contributors.first(where: { contributor in
                contributor.emails.contains(components.contributorEmail)
            }) else {
                return components.contributorEmail
            }

            let prefix = context.configuration.contributorsConfig.contributorHandlePrefix

            return "\(prefix)\(contributor.handle)"
        case .message:
            if context.sectionInfo.capitalizesMessage {
                return String(components.message.prefix(1).capitalized + components.message.dropFirst())
            } else {
                return components.message
            }
        case .sha:
            return components.sha
        case .tags:
            let outputDelims = context.configuration.formatConfig.delimiterConfig.output

            return components.tags
                .reduce("") { $0 + "\(outputDelims.left)\($1)\(outputDelims.right)" }
        }
    }
}
