//
//  DiffHandler.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import DiffFormatterCore
import DiffFormatterRouting
import DiffFormatterTelemetry
import DiffFormatterUtilities

extension ArgumentRouter {
    static let diffHandler: RouterArgumentHandling = .init { context, scheme in
        guard case let .diffable(versions, args) = scheme else {
            return .notHandled
        }

        let projDir = projectDir(context: context, scheme: scheme)

        let outputGenerator: OutputGenerator = .init(
            configuration: context.configuration,
            rawDiff: diff(
                context: context,
                scheme: scheme,
                versions: versions,
                projectDir: projDir
            ),
            version: versionHeader(context: context, scheme: scheme, projectDir: projDir),
            releaseManager: releaseManager(context: context, scheme: scheme)
        )

        log.info("Output copied to pasteboard:")

        context.output(output(generator: outputGenerator))

        return .handled
    }

    private static func output(generator: OutputGenerator) -> String {
        let result = generator.generateOutput()

        pbCopy(text: result)

        return result
    }

    private static func versionHeader(context: RoutingContext, scheme: ArgumentScheme, projectDir: String) -> String? {
        guard case let .diffable(versions, args) = scheme, !args.contains(.flag(.noShowVersion)) else {
            return nil
        }

        var versionHeader: String = versions.new

        for case let .actionable(.buildNumber, buildNumber) in args {
            return versionHeader + " (\(buildNumber))"
        }

        if var commandArgs = context.configuration.buildNumberCommandArgs,
            !commandArgs.isEmpty,
            case let exec = commandArgs.removeFirst(),
            let buildNumber = shell(
                executablePath: exec,
                arguments: commandArgs,
                currentDirectoryPath: context.configuration.currentDirectory,
                environment: ["NEW_VERSION": "\(versions.new)", "PROJECT_DIR": "\(projectDir)"]
            ) {
            versionHeader.append(" (\(buildNumber.trimmingCharacters(in: .whitespacesAndNewlines)))")
        }

        return versionHeader
    }

    private static func diff(
        context: RoutingContext,
        scheme: ArgumentScheme,
        versions: Versions,
        projectDir: String) -> String {
        for case let .actionable(.gitDiff, diff) in scheme.args {
            return diff
        }

        let git = Git(
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

    private static func projectDir(context: RoutingContext, scheme: ArgumentScheme) -> String {
        for case let .actionable(.projectDir, dir) in scheme.args {
            return dir
        }

        return context.configuration.currentDirectory
    }

    private static func releaseManager(context: RoutingContext, scheme: ArgumentScheme) -> Contributor? {
        for case let .actionable(.releaseManager, email) in scheme.args {
            return context.configuration.contributors.first { $0.email == email }
        }

        return nil
    }
}
