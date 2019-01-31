//
//  ChangeLogRunner.swift
//  DiffFormatterApp.swift
//
//  Created by Dan Loman on 11/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import class Basic.Process
import DiffFormatterCore
import DiffFormatterUtilities

struct ChangeLogRunner {
    typealias Options = GenerateCommand.Options

    func run(with options: Options, app: App, env: Environment) throws {
        let outputGenerator: OutputGenerator = .init(
            configuration: app.configuration,
            rawGitLog: log(options: options, app: app),
            version: try versionHeader(options: options, app: app, env: env),
            releaseManager: releaseManager(
                options: options,
                configuration: app.configuration
            )
        )

        app.print(output(generator: outputGenerator, options: options, app: app))
    }

    private func output(generator: OutputGenerator, options: Options, app: App) -> String {
        let result = generator.generateOutput()

        if options.toPasteBoard {
            app.print("Copying output to pasteboard", kind: .info)
            pbCopy(text: result)
        }

        return result
    }

    private func versionHeader(options: Options, app: App, env: Environment) throws -> String? {
        guard !options.noShowVersion else {
            return nil
        }

        let versionHeader: String = options.versions.new.description

        if let buildNumber = options.buildNumber {
            return versionHeader + " (\(buildNumber))"
        }

        guard
            let args = app.configuration.buildNumberCommandArgs,
            !args.isEmpty,
            let buildNumber = try getBuildNumber(
                for: options.versions.new,
                projectDir: app.configuration.projectDir,
                using: args,
                environment: env
            )?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return versionHeader
        }

        return versionHeader + " (\(buildNumber))"
    }

    private func getBuildNumber(
        for newVersion: Version,
        projectDir: String,
        using args: [String],
        environment: Environment) throws -> String? {
        guard !args.isEmpty else {
            return nil
        }

        let env: Environment = environment.merging([
            "NEW_VERSION": "\(newVersion)",
            "PROJECT_DIR": "\(projectDir)"
        ]) { $1 }

        let process: Process = .init(
            arguments: args,
            environment: env
        )

        try process.launch()
        try process.waitUntilExit()

        if let result = process.result {
            return try result.utf8Output()
        } else {
            return nil
        }
    }

    private func log(options: Options, app: App) -> String {
        if let log = options.gitLog {
            return log
        }

        let git = Git(configuration: app.configuration)

        if !options.noFetch {
            app.print("Fetching origin", kind: .info)
            git.fetch()
        }

        app.print("Generating log", kind: .info)

        return git.log(oldVersion: options.versions.old, newVersion: options.versions.new)
    }

    private func releaseManager(options: Options, configuration: Configuration) -> Contributor? {
        guard let email = options.releaseManager else {
            return nil
        }

        return configuration.contributors.first { $0.email == email }
    }
}
