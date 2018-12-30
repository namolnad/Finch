//
//  DiffHandler.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

extension ArgumentRouter {
    private typealias Versions = (old: String, new: String)

    static let diffHandler: RouterArgumentHandling = .init { context, scheme in
        guard
            let oldVersion = scheme.oldVersion,
            let newVersion = scheme.newVersion,
            case let versions = (oldVersion, newVersion) else {
                return .notHandled
        }

        let outputGenerator: Utilities.OutputGenerator = .init(
            configuration: context.configuration,
            rawDiff: diff(
                versions: versions,
                context: context,
                scheme: scheme,
                projectDir: projectDir(context: context, scheme: scheme)
            ),
            version: versionHeader(context: context, scheme: scheme),
            releaseManager: releaseManager(context: context, scheme: scheme)
        )

        log.info("Output copied to pasteboard:")

        context.output(output(generator: outputGenerator))

        return .handled
    }

    private static func output(generator: Utilities.OutputGenerator) -> String {
        let result = generator.generateOutput()

        Utilities.pbCopy(text: result)

        return result
    }

    private static func versionHeader(context: Context, scheme: ArgumentScheme) -> String? {
        guard !scheme.args.contains(.flag(.noShowVersion)) else {
            return nil
        }

        var versionHeader: String? = scheme.newVersion

        for case let .actionable(.buildNumber, buildNumber) in scheme.args {
            versionHeader?.append(" (\(buildNumber))")
            return versionHeader
        }

        if let command = context.configuration.buildNumberCommand,
            case var commandArgs = command.components(separatedBy: " "),
            !commandArgs.isEmpty,
            case let exec = commandArgs.removeFirst(),
            let buildNumber = Utilities.shell(
                executablePath: exec,
                arguments: command.components(separatedBy: " "),
                currentDirectoryPath: context.configuration.currentDirectory
            ) {
            versionHeader?.append(" (\(buildNumber.trimmingCharacters(in: .whitespacesAndNewlines)))")
        }

        return versionHeader
    }

    private static func diff(
        versions: Versions,
        context: Context,
        scheme: ArgumentScheme,
        projectDir: String) -> String {
        for case let .actionable(.gitDiff, diff) in scheme.args {
            return diff
        }

        let git = Utilities.Git(
            configuration: context.configuration,
            projectDir: projectDir
        )

        if !scheme.args.contains(.flag(.noFetch)) {
            log.info("Fetching origin")
            git.fetch()
        }

        log.info("Generating diff")

        return git.diff(oldVersion: versions.old, newVersion: versions.new)
    }

    private static func projectDir(context: Context, scheme: ArgumentScheme) -> String {
        for case let .actionable(.projectDir, dir) in scheme.args {
            return dir
        }

        return context.configuration.currentDirectory
    }

    private static func releaseManager(context: Context, scheme: ArgumentScheme) -> Contributor? {
        for case let .actionable(.releaseManager, email) in scheme.args {
            return context.configuration.contributors.first { $0.email == email }
        }

        return nil
    }
}
