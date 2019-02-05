//
//  ChangeLogInfoService.swift
//  DiffFormatterApp
//
//  Created by Dan Loman on 2/4/19.
//

import DiffFormatterUtilities
import Foundation

protocol ChangeLogInfoServiceType {
    func buildNumber(options: GenerateCommand.Options, app: App, env: Environment) throws -> String?
    func changeLog(options: GenerateCommand.Options, app: App, env: Environment) throws -> String
    // Returns a space separated string representing two versions. E.g. "0.2.1 0.3.0"
    func versionsString(app: App, env: Environment) throws -> String
}

struct ChangeLogInfoService: ChangeLogInfoServiceType {
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

    func buildNumber(options: GenerateCommand.Options, app: App, env: Environment) throws -> String? {
        if let buildNumber = options.buildNumber {
            return buildNumber
        }

        guard let args = app.configuration.resolutionCommandsConfig.buildNumber, !args.isEmpty else {
            return nil
        }

        let environment: Environment = env.merging([
            "NEW_VERSION": "\(options.versions.new)",
            "PROJECT_DIR": "\(app.configuration.projectDir)"
        ]) { $1 }

        return try Shell(env: environment)
            .run(args: args)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func changeLog(options: GenerateCommand.Options, app: App, env: Environment) throws -> String {
        if let log = options.gitLog {
            return log
        }

        let git = Git(app: app, env: env)

        if !options.noFetch {
            app.print("Fetching origin", kind: .info)
            try git.fetch()
        }

        app.print("Generating log", kind: .info)

        return try git.log(oldVersion: options.versions.old, newVersion: options.versions.new)
    }

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
