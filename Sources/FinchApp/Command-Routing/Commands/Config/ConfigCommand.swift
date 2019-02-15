//
//  ConfigCommand.swift
//  FinchApp
//
//  Created by Dan Loman on 2/14/19.
//

import FinchCore
import FinchUtilities
import Foundation
import Utility
import Yams

final class ConfigCommand: Command {
    struct Options {
        fileprivate(set) var shouldPrintExample: Bool
    }

    private typealias Binder = ArgumentBinder<Options>

    let name: String = "config"

    private let binder: Binder = .init()

    private let subparser: ArgumentParser

    init(
        meta: App.Meta,
        parser: ArgumentParser
        ) {
        self.subparser = parser.add(
            subparser: name,
            overview: .localizedStringWithFormat(
                NSLocalizedString(
                    "Assists with generation and example presentation of %@ configuration",
                    comment: "Configuration command overview"),
                meta.name
            )
        )

        bindOptions(to: binder, meta: meta)
    }

    func run(with result: ParsingResult, app: App, env: Environment) throws {
        var options: Options = .blank

        try binder.fill(parseResult: result, into: &options)

        if options.shouldPrintExample {
            let exampleConfig: Configuration = .example(projectDir: app.configuration.projectDir)

            app.print(try YAMLEncoder().encode(exampleConfig))
        }
    }

    private func bindOptions(to binder: Binder, meta: App.Meta) {
        binder.bind(option: subparser.add(
            option: "--example",
            shortName: "-v",
            kind: Bool.self,
            usage: "Don't fetch origin before auto-generating log"
        )) { $0.shouldPrintExample = $1 }
    }
}

extension ConfigCommand.Options {
    fileprivate static let blank: ConfigCommand.Options = .init(
        shouldPrintExample: false
    )
}
