//
//  Strings.swift
//  FinchApp
//
//  Created by Dan Loman on 2/22/19.
//

// swiftlint:disable line_length
enum Strings {
    enum App {
        private static let repoBaseUrl: String = "https://github.com/namolnad"

        static func overview(appName: String) -> String {
            return "\(appName) is a flexible tool for generating well-formatted changelogs between application versions"
        }

        static func seeAlso(appName: String) -> String {
            return "Visit \(repoBaseUrl)/\(appName) for more information"
        }

        enum Options {
            static var projectDir: String = "Path to project if command is run from separate directory"

            static func showVersion(appName: String) -> String {
                return "Displays current \(appName) version and build number"
            }

            static var verbose: String = "Run command with verbose output"
        }
    }

    enum Compare {
        static let commandName: String = "compare"

        static let commandOverview: String = "Compares two versions and generates a formatted changelog"

        enum Options {
            static let buildNumber: String = "Build number string to be included in version header. Takes precedence over build number command in config. e.g. `6.19.1 (6258)`"

            static func gitLog(appName: String) -> String {
                return "Pass in the git-log string directly vs having \(appName) generate it"
            }

            static let noFetch: String = "Don't fetch origin before auto-generating log"

            static let normalizeTags: String = "Normalize all commit tags by lowercasing prior to running comparison"

            static let noShowVersion: String = "Hide version header"

            static let releaseManager: String = "The release manager's email. e.g. `--release-manager=$(git config --get user.email)`"

            static let requireAllTags: String = "Requires a commit to have all section tags to be assigned to said section"

            static let toPasteboard: String = "Copy output to pasteboard in addition to stdout"

            static let versions: String = "<version_1> <version_2> Use explicit versions for the changelog instead of auto-resolving"
        }

        enum Progress {
            static let toPasteboard: String = "Copying output to pasteboard"
        }

        enum Error {
            static let noVersions: String = "Unable to procure versions string. Ensure semantic-version branches or tags exist"

            static let unableToResolve: String = "Unable to automatically resolve versions. Pass versions in directly through --versions option"

            static let versions: String = "Must receive 2 versions to properly compare and generate changelog"
        }
    }

    enum Config {
        static let commandName: String = "config"

        static func commandOverview(appName: String) -> String {
            return "Assists with generation and example presentation of \(appName) configuration"
        }

        enum Options {
            static let showExample: String = "Display example config"
        }
    }

    enum Error {
        static func formatted(errorMessage: String) -> String {
            return "Error: \(errorMessage)"
        }
    }
}
// swiftlint:enable line_length
