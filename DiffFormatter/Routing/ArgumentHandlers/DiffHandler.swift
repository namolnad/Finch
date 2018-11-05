//
//  DiffHandler.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

extension ArgumentRouter {
    static let diffHandler: RouterArgumentHandling = .init { context, args in
        var args = args

        guard let oldVersion = args.popLast(), let newVersion = args.popLast() else {
            return .notHandled
        }

        let commandValues = args.compactMap(Argument.commands)

        let versionHeader: String? = args.contains("--\(Command.noShowVersion.rawValue)") ? nil : newVersion

        let releaseManager = commandValues
            .first { $0.command == .releaseManager }
            .flatMap { email in context.configuration.users.first { $0.email == email.value } }

        let projectDir = commandValues
            .first { $0.command == .projectDir }?
            .value ?? context.configuration.currentDirectory

        let rawDiff = commandValues
            .first { $0.command == .gitDiff }?
            .value ??
            GitDiffer(configuration: context.configuration,
                      projectDir: projectDir,
                      oldVersion: oldVersion,
                      newVersion: newVersion).diff

        let outputGenerator = OutputGenerator(
            configuration: context.configuration,
            rawDiff: rawDiff,
            version: versionHeader,
            releaseManager: releaseManager
        )

        output(generator: outputGenerator)

        return .handled
    }

    private static func output(generator: OutputGenerator) {
        let result = generator.generatedOutput()

        pbCopy(text: result)

        print("Output copied to pasteboard: \(result)")
    }
}
