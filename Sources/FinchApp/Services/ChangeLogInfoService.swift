//
//  ChangeLogInfoService.swift
//  FinchApp
//
//  Created by Dan Loman on 2/4/19.
//

import FinchUtilities
import Foundation

/// A protocol defining the service for changelog info.
protocol ChangeLogInfoServiceType {
    /// Returns the build number for the new version.
    func buildNumber(options: CompareCommand.Options, app: App) throws -> String?

    /// Returns the raw changelog (git log) between the two compared versions.
    func changeLog(options: CompareCommand.Options, app: App) throws -> String

    /**
     * Returns a space-separated string representing two
     * versions. E.g. "0.2.1 0.3.0"
     */
    func versionsString(app: App) throws -> String
}

/// A concrete type conforming to `ChangeLogInfoServiceType` protocol
struct ChangeLogInfoService: ChangeLogInfoServiceType {
    /// :nodoc:
    enum Error: LocalizedError {
        case noVersionsString

        var failureReason: String? {
            switch self {
            case .noVersionsString:
                return Strings.Compare.Error.noVersions
            }
        }
    }

    // swiftlint:disable line_length
    private var semVerRegex: String {
        return "(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?"
    }
    // swiftlint:enable line_length

    /**
     * See `ChangeLogInfoServiceType.buildNumber(options:app:)`
     * for definition.
     */
    func buildNumber(options: CompareCommand.Options, app: App) throws -> String? {
        if let buildNumber = options.buildNumber {
            return buildNumber
        }

        guard let args = app.configuration.resolutionCommandsConfig.buildNumber, !args.isEmpty else {
            return nil
        }

        let environment: Environment = app.environment.merging([
            "NEW_VERSION": "\(options.versions.new)",
            "PROJECT_DIR": app.configuration.projectDir
        ]) { $1 }

        return try Shell(env: environment)
            .run(args: [args])
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /**
     * See `ChangeLogInfoServiceType.changeLog(options:app:)`
     * for definition.
     */
    func changeLog(options: CompareCommand.Options, app: App) throws -> String {
        if let log = options.gitLog {
            return log
        }

        let git = Git(app: app)

        if !options.noFetch {
            app.print("Fetching origin", kind: .info)
            try git.fetch()
        }

        app.print("Generating changelog", kind: .info)

        return try git.log(oldVersion: options.versions.old, newVersion: options.versions.new)
    }

    /**
     * See `ChangeLogInfoServiceType.versionString(app:)`
     * for definition.
     */
    func versionsString(app: App) throws -> String {
        // First try for custom command
        if let value = app.configuration.resolutionCommandsConfig.versions {
            let environment = app.environment.merging(["PROJECT_DIR": app.configuration.projectDir]) { $1 }

            let shell = Shell(env: environment, verbose: app.verbose)
            return try shell.run(args: [value])
        }

        let git = Git(app: app)

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
