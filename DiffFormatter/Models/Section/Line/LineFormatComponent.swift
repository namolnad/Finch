//
//  LineFormatComponent.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/23/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

extension Section.Line {
    enum FormatComponent: String {
        case commitTypeHyperlink = "commit_type_hyperlink"
        case contributorEmail = "contributor_email"
        case contributorHandle = "contributor_handle"
        case message
        case sha
        case tags
    }
}

extension Section.Line.FormatComponent: Decodable {}

extension Section.Line.FormatComponent: LineOutputtable {
    func output(components: Section.Line.Components, context: Section.Line.Context) -> String {
        switch self {
        case .commitTypeHyperlink:
            var urlTitle = "Commit"
            var url = "\(context.configuration.repoBaseUrl)/commit/\(components.sha)"
            if let prNum = components.pullRequestNumber {
                urlTitle = "PR #\(prNum)"
                url = "\(context.configuration.repoBaseUrl)/pull/\(prNum)"
            }
            return "[\(urlTitle)](\(url))"
        case .contributorEmail:
            return components.contributorEmail
        case .contributorHandle:
            guard let contributor = context.configuration.contributors.first(where: { $0.email == components.contributorEmail }) else {
                return components.contributorEmail
            }

            return "\(context.configuration.contributorHandlePrefix)\(contributor.handle)"
        case .message:
            if context.sectionInfo.capitalizesMessage {
                return components.message.capitalized
            } else {
                return components.message
            }
        case .sha:
            return components.sha
        case .tags:
            return components.tags
                .reduce("") { $0 + "\(context.configuration.delimiterConfig.output.left)\($1)\(context.configuration.delimiterConfig.output.right)" }
        }
    }
}
