//
//  UsageHandler.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

extension ArgumentRouter {
    private static let usageArguments: [Argument] = [.flag(.help), .flag(.helpAbbreviated)]

    static let usageHandler: RouterArgumentHandling = .init { context, scheme in
        guard scheme.args.contains(where: usageArguments.contains) else {
            return .notHandled
        }

        // NOTE: - Long term, this should defer to sub-handlers for command-specific usage

        print(usageInformation(context: context))

        return .handled
    }

    private static func usageInformation(context: Context)-> String {
        return """

        \(context.app.name) Info:
            -h, --help
                Displays this dialog
            -v, --version
                Displays \(context.app.name) version information

        Diff Formatting:
            The first 2 arguments must be (branch or tag) version strings, given as:

            `\(context.app.name) OLD_VERSION NEW_VERSION`

        Diff-Modifying Arguments:
            --no-show-version
                The ability to hide the version header
            --release-manager
                The release manager's email, e.g. `--release-manager=$(git config --get user.email)`
            --project-dir
                Project directory if \(context.app.name) is not being called from project directory
            --git-diff
                Manually-passed git diff in expected format. See README for format details.

        Configuration:
            Configuration instructions available in the README.


        Additional information available at: https://github.com/namolnad/\(context.app.name)

        """
    }
}
