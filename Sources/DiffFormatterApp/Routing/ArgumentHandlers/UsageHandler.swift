//
//  UsageHandler.swift
//  DiffFormatterApp.swift
//
//  Created by Dan Loman on 11/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import DiffFormatterRouting

extension ArgumentRouter {
    private static let usageArguments: [Argument] = [.flag(.help), .flag(.helpAbbreviated)]

    static let usageHandler: RouterArgumentHandling = .init { context, scheme in
        guard scheme.args.contains(where: usageArguments.contains) else {
            return .notHandled
        }

        // NOTE: - Long term, this should defer to sub-handlers for command-specific usage

        context.output(usageInformation(context: context))

        return .handled
    }

    // swiftlint:disable line_length
    private static func usageInformation(context: RoutingContext) -> String {
        return """

        \(context.app.name) Info:
            -h, --help
                Displays this dialog
            -v, --version
                Displays \(context.app.name) version information

        Diff Formatting:
            The first 2 arguments must be (branch or tag) version strings, given as:

            `\(context.app.name) OLD_VERSION NEW_VERSION`

        Other Arguments:
            --no-show-version
                The ability to hide the version header
            --release-manager
                The release manager's email. e.g. `--release-manager=$(git config --get user.email)`
            --project-dir
                Project directory if \(context.app.name) is not being called from project directory
            --git-diff
                Manually-passed git diff in expected format. See README for format details.
            --no-fetch
                Don't fetch origin before auto-generating diff
            --build-number
                Build number string to be included in version header. Takes precedence over build number command in config. e.g. `6.19.1 (6258)`

        Configuration:
            Configuration instructions available in the README.


        Additional information available at: https://github.com/namolnad/\(context.app.name)

        """
    }
    // swiftlint:enable line_length
}
