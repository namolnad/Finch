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

    func route(arguments: [String]) {
        var args = Array(arguments
            .lazy
            .filter { !$0.contains(appName) } // Remove call of self
            .reversed())

        guard let primaryArg = args.popLast() else {
            return
        }

        let lines = Output.primary(input: primaryArg)
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }

        var features: [String] = []

        var bugFixes: [String] = []

        var platformImprovements: [String] = []

        lines.forEach {
            if Tag.fixTags.contains(where: $0.contains) {
                bugFixes.append($0)
            } else if Tag.platformTags.contains(where: $0.contains) {
                platformImprovements.append($0)
            } else {
                features.append($0)
            }
        }

        let commandValues = args.compactMap(Argument.commands)

        let versionHeader = commandValues
            .first { $0.command == .version }

        let releaseManager = commandValues
            .first { $0.command == .releaseManager }
            .flatMap { User.init(rawValue: $0.value) }

        output(.init(
            version: versionHeader?.value,
            releaseManager: releaseManager,
            features: features,
            bugFixes: bugFixes,
            platformImprovements: platformImprovements))
    }

    private func output(_ output: Output) {
        let result = output.finalOutput
        pbCopy(text: result)

        print("Output copied to pasteboard: \(result)")
    }
}
