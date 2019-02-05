//
//  VersionStringService.swift
//  DiffFormatterApp
//
//  Created by Dan Loman on 2/4/19.
//

import DiffFormatterUtilities
import Foundation

protocol VersionStringProviding {
    // Returns a space separated string representing two versions. E.g. "0.2.1 0.3.0"
    func versionsString(app: App, env: Environment) throws -> String
}

struct VersionStringService: VersionStringProviding {
    enum Error: LocalizedError {
        case noVersionsString

        var failureReason: String? {
            switch self {
            case .noVersionsString:
                return NSLocalizedString(
                    "Unable to procure versions string. Ensure semantic-version branches or tags exist",
                    comment: "Error message when failed to create versions string"
                )
            }
        }
    }

    // swiftlint:disable line_length
    private var semVerRegex: String {
        return "(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?"
    }
    // swiftlint:enable line_length

    func versionsString(app: App, env: Environment) throws -> String {
        // First try for custom command
        if let value = app.configuration.resolutionCommandsConfig.versions {
            let environment = env.merging(["PROJECT_DIR": app.configuration.projectDir]) { $1 }

            let shell = Shell(env: environment, verbose: app.options.verbose)
            return try shell.run(args: value)
        }

        let git = Git(app: app, env: env)

        // Search for 2 most recent version branches
        if case let value = try git.versionsStringUsingBranches(semVerRegex: semVerRegex), !value.isEmpty {
            return value
        }

        // Search for 2 most recent tags
        if case let value = try git.versionsStringUsingTags(), !value.isEmpty {
            return value
        }

        throw Error.noVersionsString
    }
}
