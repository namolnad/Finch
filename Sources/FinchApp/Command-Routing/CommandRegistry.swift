//
//  CommandRegistry.swift
//  FinchApp
//
//  Created by Dan Loman on 1/29/19.
//

import Foundation
import Utility
import var Basic.stdoutStream

final class CommandRegistry {
    typealias Binder = ArgumentBinder<App.Options>

    private let binder: Binder = .init()

    private var commands: [Command] = []

    private let parser: ArgumentParser

    init(meta: App.Meta) {
        self.parser = .init(
            usage: "<command> [--option]...",
            overview: .localizedStringWithFormat(
                NSLocalizedString(
                    "%@ is a flexible tool for generating well-formatted changelogs between application versions",
                    comment: "App overview description"
                ),
                meta.name
            ),
            seeAlso: .localizedStringWithFormat(
                NSLocalizedString(
                    "Visit https://github.com/namolnad/%@ for more information",
                    comment: "More information and website referral description"
                ),
                meta.name
            )
        )

        bindOptions(to: binder, using: parser, meta: meta)
    }

    // swiftlint:disable large_tuple
    func parse(arguments: [String]) throws -> (String?, App.Options, ParsingResult) {
        let result = try parser.parse(arguments)

        var options: App.Options = .blank

        try binder.fill(parseResult: result, into: &options)

        return (result.subparser(parser), options, result)
    }
    // swiftlint:enable large_tuple

    func printUsage() {
        parser.printUsage(on: stdoutStream)
    }

    func register(command: (ArgumentParser, Binder) -> Command) {
        self.commands.append(command(parser, binder))
    }

    func runCommand(named name: String, with result: ParsingResult, app: App, env: Environment) throws {
        guard let command = commands.first(where: { $0.name == name }) else {
            return
        }

        return try command.run(with: result, app: app, env: env)
    }

    private func bindOptions(to binder: Binder, using parser: ArgumentParser, meta: App.Meta) {
        binder.bind(option: parser.add(
            option: "--version",
            shortName: "-V",
            kind: Bool.self,
            usage: .localizedStringWithFormat(
                NSLocalizedString(
                    "Displays current %@ version and build number",
                    comment: "App version option description"
                ),
                meta.name
            )
        )) { $0.shouldPrintVersion = $1 }
    }
}
