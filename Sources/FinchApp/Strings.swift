//
//  Strings.swift
//  FinchApp
//
//  Created by Dan Loman on 2/22/19.
//

// swiftlint:disable line_length
enum Strings {
    private static let appName: String = "Finch"

    private static let repoBaseUrl: String = "https://github.com/namolnad"

    enum App {
        static let overview: String = "A flexible tool for generating well-formatted changelogs between application versions"

        static var seeAlso: String {
            return "Visit \(repoBaseUrl)/\(appName) for more information"
        }

        enum Options {
            static var configPath: String = "Path to config"

            static var projectDir: String = "Path to project if command is run from separate directory"

            static var showVersion: String {
                return "Displays current \(appName) version and build number"
            }

            static var verbose: String = "Run with verbose output"
        }
    }

    enum Compare {
        static let commandName: String = "compare"

        static let commandOverview: String = "Compares two versions and generates a formatted changelog"

        enum Options {
            static let buildNumber: String = "Build number string to be included in version header. Takes precedence over build number command in config. e.g. `6.19.1 (6258)`"

            static var gitLog: String {
                return "Pass in the git-log string directly vs having \(appName) generate it"
            }

            static let noFetch: String = "Don't fetch origin before auto-generating log"

            static let normalizeTags: String = "Normalize all commit tags by lowercasing prior to running comparison"

            static let noShowVersion: String = "Hide version header"

            static let releaseManager: String = "The release manager's email. e.g. `--release-manager=$(git config --get user.email)`"

            static let requiredTags: String = "A set of tags required for commit presence in the final output. NOTE: Must be enclosed in quotes"

            static let versions: String = "'<version_1> <version_2>' Use explicit versions for the changelog instead of auto-resolving. NOTE: Must be enclosed in quotes"

            static let useNewlineChar: String = "Encodes the line breaks as '\n' and not as the new-line value"
        }

        enum Error {
            static let noVersions: String = "Unable to procure versions string. Ensure semantic-version branches or tags exist"

            static let unableToResolve: String = "Unable to automatically resolve versions. Pass versions in directly through --versions option"

            static let versions: String = "Must receive 2 versions to properly compare and generate changelog"
        }
    }

    enum Config {
        static let commandName: String = "config"

        static var commandOverview: String {
            return "Assists with generation and example presentation of \(appName) configuration"
        }

        enum Example {
            static let commandName: String = "show-example"
            static let commandOverview: String = "Display example config"
        }
    }

    enum Error {
        static func formatted(errorMessage: String) -> String {
            return "Error: \(errorMessage)"
        }

        static let unsupportedConfigMode: String = "Not a valid subcommand"
    }
}
// swiftlint:enable line_length
