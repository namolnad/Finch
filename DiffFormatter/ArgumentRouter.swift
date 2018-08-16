//
//  ArgumentRouter.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

let appName: String = "DiffFormatter"

struct ArgumentRouter {
    private let configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
    }
}

extension ArgumentRouter {
    func route(arguments: [String]) {
        var args = Array(arguments
            .filter { !$0.contains(appName) }
            .reversed())

        guard let primaryArg = args.popLast() else {
            return
        }

        let commandValues = args.compactMap(Argument.commands)

        let versionHeader = commandValues
            .first { $0.command == .version }?
            .value

        let releaseManager = commandValues
            .first { $0.command == .releaseManager }
            .flatMap { email in configuration.users.first { $0.email == email.value } }

        let outputGenerator = OutputGenerator(
            configuration: configuration,
            rawDiff: primaryArg,
            version: versionHeader,
            releaseManager: releaseManager
        )

        output(generator: outputGenerator)
    }

    private func output(generator: OutputGenerator) {
        let result = generator.generatedOutput()

        pbCopy(text: result)

        print("Output copied to pasteboard: \(result)")
    }
}
