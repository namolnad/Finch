//
//  VersionResolver.swift
//  DiffFormatterApp
//
//  Created by Dan Loman on 2/3/19.
//

import DiffFormatterUtilities

struct VersionResolver {
    enum Error: Swift.Error {
        case unexpectedVersionStringsCount
        case unableToResolveVersion
    }

    private var semVerRegex: String {
        return "(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?"
    }

    func resolve(app: App, env: Environment) throws -> (old: Version, new: Version) {
        // First try for custom command
        if let value = app.configuration.resolutionCommandsConfig.versions {
            let versionsString = try Shell.run(args: value, env: env)
            return try versions(versionString: versionsString)
        }

        // Search for 2 most recent version branches
        if let value = try versionsUsingBranches(app: app, env: env) {
            return value
        }

        // Search for 2 most recent tags
        if let value = try versionsUsingTags(env: env) {
            return value
        }

        throw Error.unableToResolveVersion
    }

    private func versions(versionString: String) throws -> (old: Version, new: Version) {
        guard case let versionStrings = versionString.split(separator: " "),
            versionStrings.count == 2,
            let firstVersionString = versionStrings.first,
            let secondVersionString = versionStrings.last else {
                throw Error.unexpectedVersionStringsCount
        }
        let firstVersion = try Version(argument: String(firstVersionString))
        let secondVersion = try Version(argument: String(secondVersionString))

        if firstVersion < secondVersion {
            return (firstVersion, secondVersion)
        } else {
            return (secondVersion, firstVersion)
        }
    }

    private func versionsUsingTags(env: Environment) throws -> (old: Version, new: Version)? {
        let gitArgs: [String] = [
            "git",
            "tag",
            "-l",
            "--sort=v:refname",
            "|",
            "tail",
            "-2"
        ]

        let versionsString = try Shell.run(args: gitArgs, env: env)

        if versionsString.split(separator: " ").count != 2 {
            return nil
        }

        return try versions(versionString: versionsString)
    }

    private func versionsUsingBranches(app: App, env: Environment) throws -> (old: Version, new: Version)? {
        let gitArgs: [String] = [
            "git",
            "branch",
            "-r",
            "--list",
            "|",
            "grep",
            "-E",
            "\(app.configuration.gitBranchPrefix)\(semVerRegex)",
            "|",
            "sort",
            "-V",
            "|",
            "tail",
            "-2"
        ]

        let versionsString = try Shell.run(args: gitArgs, env: env)

        if versionsString.split(separator: " ").count != 2 {
            return nil
        }

        return try versions(versionString: versionsString)
    }
}
