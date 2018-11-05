//
//  UsageHandler.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

extension ArgumentRouter {
    private static let usageArguments: [String] = ["--help", "-h"]

    static let usageHandler: RouterArgumentHandling = .init { _, args in
        guard args.contains(where: usageArguments.contains) else {
            return .notHandled
        }

        // NOTE: - Long term, this should defer to sub-handlers for command-specific usage

        print("\(usageInformation)")

        return .handled
    }

    private static let usageInformation: String = """

DiffFormatter Info:

-h, --help
    Displays this dialog
-v, --version
    Displays DiffFormatter version information


Typical Usage — DiffFormatting:


The first two arguments received must be the version strings in the order: OLD_VERSION NEW_VERSION
Note: - branch or tag values are both acceptable version strings

To modify the output diff, other accepted arguments are:

--no-show-version
    The ability to hide the version header
--release-manager
    The release manager
--project-dir
    Project directory if DiffFormatter is not being called from project directory
--git-diff
    Manual git diff. Must be received in format: git log --left-right --graph --cherry-pick --oneline --format=format:'&&&%H&&& - @@@%s@@@###%ae###' --date=short OLD_VERSION...NEW_VERSION

"""
}
