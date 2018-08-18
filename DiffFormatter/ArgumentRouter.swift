//
//  ArgumentRouter.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct ArgumentRouter {
    private let configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
    }
}

extension ArgumentRouter {
    @discardableResult
    func route(arguments: [String]) -> Bool {
        var args = Array(arguments
            .filter { !$0.contains(appName) }
            .reversed())

        guard !args.contains("--help") else {
            print("Please refer to the README for usage instructions")
            return true
        }

        guard let oldVersion = args.popLast() else {
            return false
        }
        guard let newVersion = args.popLast() else {
            return false
        }

        let commandValues = args.compactMap(Argument.commands)

        let versionHeader = commandValues
            .first { $0.command == .version }?
            .value

        let releaseManager = commandValues
            .first { $0.command == .releaseManager }
            .flatMap { email in configuration.users.first { $0.email == email.value } }

        let projectDir = commandValues
            .first { $0.command == .projectDir }?
            .value ?? configuration.currentDirectory

        let rawDiff = commandValues
            .first { $0.command == .gitDiff }?
            .value ??
            GitDiffer(configuration: configuration,
                projectDir: projectDir,
                oldVersion: oldVersion,
                newVersion: newVersion).diff



        let outputGenerator = OutputGenerator(
            configuration: configuration,
            rawDiff: rawDiff,
            version: versionHeader,
            releaseManager: releaseManager
        )

        output(generator: outputGenerator)

        return true
    }

    private func output(generator: OutputGenerator) {
        let result = generator.generatedOutput()

        pbCopy(text: result)

        print("Output copied to pasteboard: \(result)")
    }
}
