//
//  Strings.swift
//  FinchApp
//
//  Created by Dan Loman on 2/22/19.
//

import Foundation

// swiftlint:disable line_length
enum Strings {
    enum Error {
        static func formatted(_ errorMessage: String) -> String {
            return .localizedStringWithFormat(
                NSLocalizedString(
                    "Error: %@",
                    comment: "Formatted error message"
                ),
                errorMessage
            )
        }

        static let unableToResolve: String = NSLocalizedString(
            "Unable to automatically resolve versions. Pass versions in directly through --versions option",
            comment: "Error message indicating inability to auto-resolve versions"
        )

        static let noVersions: String = NSLocalizedString(
            "Unable to procure versions string. Ensure semantic-version branches or tags exist",
            comment: "Error message when failed to create versions string"
        )
    }

    enum App {
        static func overview(appName: String) -> String {
            return .localizedStringWithFormat(
                NSLocalizedString(
                    "%@ is a flexible tool for generating well-formatted changelogs between application versions",
                    comment: "App overview description"
                ),
                appName
            )
        }

        static func seeAlso(appName: String) -> String {
            return .localizedStringWithFormat(
                NSLocalizedString(
                    "Visit https://github.com/namolnad/%@ for more information",
                    comment: "More information and website referral description"
                ),
                appName
            )
        }

        enum Options {
            static func showVersion(appName: String) -> String {
                return .localizedStringWithFormat(
                    NSLocalizedString(
                        "Displays current %@ version and build number",
                        comment: "App version option description"
                    ),
                    appName
                )
            }

            static var verbose: String = "Run command with verbose output"

            static var projectDir: String = "Path to project if command is run from separate directory"
        }
    }

    enum Compare {
        static let commandName: String = "compare"

        static let commandOverview: String = "Compares two versions and generates a formatted changelog"

        enum Options {
            static let noFetch: String = "Don't fetch origin before auto-generating log"

            static func gitLog(appName: String) -> String {
                return .localizedStringWithFormat(
                    NSLocalizedString(
                        "Pass in the git-log string directly vs having %@ generate it. See README for details",
                        comment: "Git log option description"
                    ),
                    appName
                )
            }

            static let versions: String = "<version_1> <version_2> Use explicit versions for the changelog instead of auto-resolving"

            static let buildNumber: String = "Build number string to be included in version header. Takes precedence over build number command in config. e.g. `6.19.1 (6258)`"

            static let normalizeTags: String = "Normalize all commit tags by lowercasing prior to running comparison"

            static let noShowVersion: String = "Hides version header"

            static let releaseManager: String = "The release manager's email. e.g. `--release-manager=$(git config --get user.email)`"

            static let toPasteboard: String = "Copy output to pasteboard in addition to stdout"
        }

        enum Actions {
            static let toPasteboard: String = "Copying output to pasteboard"
        }

        enum Error {
            static let versions: String = "Must receive 2 versions to properly compare and generate changelog"
        }
    }

    enum Config {
        static let commandName: String = "config"

        static func commandOverview(appName: String) -> String {
            return .localizedStringWithFormat(
                NSLocalizedString(
                    "Assists with generation and example presentation of %@ configuration",
                    comment: "Configuration command overview"),
                appName
            )
        }

        enum Options {
            static let showExample: String = "Displays example config"
        }
    }
}
// swiftlint:enable line_length
