//
//  LineFormatComponent.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/23/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

enum LineFormatComponent: String {
    case commitTypeHyperlink = "commit_type_hyperlink"
    case contributorEmail = "contributor_email"
    case contributorHandle = "contributor_handle"
    case message
    case sha
    case tags
}

extension LineFormatComponent: Decodable {}

extension LineFormatComponent: LineOutputtable {
    func output(components: LineComponents, configuration: Configuration) -> String {
        switch self {
        case .commitTypeHyperlink:
            var urlTitle = "Commit"
            var url = "\(configuration.repoBaseUrl)/commit/\(components.sha)"
            if let prNum = components.pullRequestNumber {
                urlTitle = "PR #\(prNum)"
                url = "\(configuration.repoBaseUrl)/pull/\(prNum)"
            }
            return "[\(urlTitle)](\(url))"
        case .contributorEmail:
            return components.contributorEmail
        case .contributorHandle:
            guard let contributor = configuration.contributors.first(where: { $0.email == components.contributorEmail }) else {
                return components.contributorEmail
            }

            return "\(configuration.contributorHandlePrefix)\(contributor.handle)"
        case .message:
            return components.message
        case .sha:
            return components.sha
        case .tags:
            return components.tags
                .reduce("") { $0 + "\(configuration.delimiterConfig.output.left)\($1)\(configuration.delimiterConfig.output.right)" }
        }
    }
}
