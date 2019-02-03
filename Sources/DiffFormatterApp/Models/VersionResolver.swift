//
//  VersionResolver.swift
//  DiffFormatterApp
//
//  Created by Dan Loman on 2/3/19.
//

import DiffFormatterUtilities
import Foundation

struct VersionResolver {
    enum Error: LocalizedError {
        case unableToResolveVersion

        var failureReason: String? {
            switch self {
            case .unableToResolveVersion:
                return NSLocalizedString(
                    "Unable to automatically resolve versions. Pass versions in directly through --versions option",
                    comment: "Error message indicating inability to auto-resolve versions"
                )
            }
        }
    }

    // swiftlint:disable line_length
    private var semVerRegex: String {
        return "(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?"
    }
    // swiftlint:enable line_length

    func resolve(app: App, env: Environment) throws -> (old: Version, new: Version) {
        // First try for custom command
        if let value = app.configuration.resolutionCommandsConfig.versions {
            let environment = env.merging(["PROJECT_DIR": app.configuration.projectDir]) { $1 }

            let shell = Shell(env: environment, verbose: app.options.verbose)
            let versionsString = try shell.run(args: value)

            if let value = try versions(versionString: versionsString) {
                return value
            }
        }

        let git = Git(app: app, env: env)

        // Search for 2 most recent version branches
        let branchesVersionsString = try git.versionsStringUsingBranches(semVerRegex: semVerRegex)
        if let value = try versions(versionString: branchesVersionsString) {
            return value
        }

        // Search for 2 most recent tags
        let tagsVersionsString = try git.versionsStringUsingTags()
        if let value = try versions(versionString: tagsVersionsString) {
            return value
        }

        throw Error.unableToResolveVersion
    }

    private func versions(versionString: String) throws -> (old: Version, new: Version)? {
        guard case let versionStrings = versionString.split(separator: " "),
            versionStrings.count == 2,
            let firstVersionString = versionStrings.first,
            let secondVersionString = versionStrings.last else {
                return nil
        }
        let firstVersion = try Version(argument: String(firstVersionString))
        let secondVersion = try Version(argument: String(secondVersionString))

        if firstVersion < secondVersion {
            return (firstVersion, secondVersion)
        } else {
            return (secondVersion, firstVersion)
        }
    }
}
