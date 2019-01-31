//
//  CommandRegistry.swift
//  DiffFormatterApp
//
//  Created by Dan Loman on 1/29/19.
//

import Foundation
import Utility
import var Basic.stdoutStream

final class CommandRegistry {
    private typealias Binder = ArgumentBinder<App.Options>

    private let binder: Binder = .init()

    private var commands: [Command] = []

    private let parser: ArgumentParser

    init(meta: App.Meta) {
        // swiftlint:disable line_length
        self.parser = .init(
            usage: "generate <version1> <version2> [--option]...",
            overview: "\(meta.name) is a flexible tool for generating well-formatted changelogs between application versions",
            seeAlso: "Visit https://github.com/namolnad/\(meta.name) for more information"
        )
        // swiftlint:enable line_length

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

    func register(command: (ArgumentParser) -> Command) {
        self.commands.append(command(parser))
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
            usage: "Displays current \(meta.name) version and build number"
        )) { $0.shouldPrintVersion = $1 }

        binder.bind(option: parser.add(
            option: "--verbose",
            shortName: "-v",
            kind: Bool.self,
            usage: "Runs commands with verbose output"
        )) { $0.verbose = $1 }

        binder.bind(option: parser.add(
            option: "--project-dir",
            kind: PathArgument.self,
            usage: "Path to project if command is run from separate directory"
        )) { $0.projectDir = $1.path.asString }
    }
}
