//
//  ConfigCommand.swift
//  FinchApp
//
//  Created by Dan Loman on 2/14/19.
//

import FinchCore
import FinchUtilities
import Utility
import Yams

/// Command to run configuration-centric operations.
final class ConfigCommand: Command {
    /// ConfigCommand options received from the commandline.
    struct Options {
        /// Print an example config.
        fileprivate(set) var shouldPrintExample: Bool
    }

    private enum Mode: String {
        case showExample = "show-example"
    }

    private typealias Binder = ArgumentBinder<Options>

    /// ConfigCommand's name.
    let name: String = Strings.Config.commandName

    private let binder: Binder = .init()

    private let subparser: ArgumentParser

    /// :nodoc:
    init(meta: App.Meta, parser: ArgumentParser) {
        self.subparser = parser.add(
            subparser: name,
            overview: Strings.Config.commandOverview(appName: meta.name)
        )

        subparser.add(
            subparser: Mode.showExample.rawValue,
            overview: Strings.Config.Options.showExample
        )

        bindOptions(to: binder, meta: meta)
    }

    /// Runs ConfigCommand with the given result, app, and env.
    func run(with result: ParsingResult, app: App, env: Environment) throws {
        var options: Options = .blank

        try binder.fill(parseResult: result, into: &options)

        if options.shouldPrintExample {
            let exampleConfig: Configuration = .example(projectDir: app.configuration.projectDir)

            app.print(try YAMLEncoder().encode(exampleConfig))
        }
    }

    private func bindOptions(to binder: Binder, meta: App.Meta) {
        binder.bind(parser: subparser) { $0.shouldPrintExample = $1 == Mode.showExample.rawValue }
    }
}

extension ConfigCommand.Options {
    fileprivate static let blank: ConfigCommand.Options = .init(
        shouldPrintExample: false
    )
}
