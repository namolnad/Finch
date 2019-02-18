//
//  Line_FormatComponent.swift
//  Finch
//
//  Created by Dan Loman on 11/23/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

/*
 * Format components are pieces of strings blah blah
 */
enum FormatComponent: String {
    case commitTypeHyperlink = "commit_type_hyperlink"
    case contributorEmail = "contributor_email"
    case contributorHandle = "contributor_handle"
    case message
    case sha
    case tags
}

extension FormatComponent: Codable {}

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
                return components.message.capitalized
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
