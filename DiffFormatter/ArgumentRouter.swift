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

    func route(arguments: [String]) {
        var args = Array(arguments
            .lazy
            .filter { !$0.contains(appName) } // Remove call of self
            .reversed())

//        guard let primaryArg = args.popLast() else {
//            return
//        }
//
        let primaryArg = testInput

        let patternCreator = FindReplacePatternCreator(configuration: configuration)

        let lines = Output.primaryOutput(for: patternCreator.patterns, with: primaryArg)
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }

        var sections: [String: Section] = [:]

        lines.forEach { line in
            if let sectionInfo = configuration.sectionInfos.first(where: { $0.tags.contains(where: line.contains) }) {
                sections[sectionInfo.title, default: Section(info: sectionInfo, lines: [])].lines.append(line)
            } else {
                sections[SectionInfo.defaultFeaturesInfo.title, default: Section(info: .defaultFeaturesInfo, lines: [])].lines.append(line)
            }

        }

        let commandValues = args.compactMap(Argument.commands)

        let versionHeader = commandValues
            .first { $0.command == .version }

        let releaseManager = commandValues
            .first { $0.command == .releaseManager }
            .flatMap { email in configuration.users.first { $0.email == email.value } } // Unsure about this logic

        output(Output(
            version: versionHeader?.value,
            releaseManager: releaseManager,
            sections: configuration.sectionInfos.compactMap { sections[$0.title] }
            )
        )
    }

    private func output(_ output: Output) {
        let result = output.finalOutput
        pbCopy(text: result)

        print("Output copied to pasteboard: \(result)")
    }
}
