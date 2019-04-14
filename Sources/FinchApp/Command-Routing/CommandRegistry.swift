//
//  CommandRegistry.swift
//  FinchApp
//
//  Created by Dan Loman on 1/29/19.
//

import Commandant

/// A class for registering, parsing and running commands.
//enum Err: Error {
//
//}

//final class CommandRegistr {
//    /// :nodoc:
//
//    private let parser: ArgumentParser
//
//    /// :nodoc:
//    init(meta: App.Meta) {
//        self.parser = .init(
//            usage: "<command> [--option]...",
//            overview: Strings.App.overview(appName: meta.name),
//            seeAlso: Strings.App.seeAlso(appName: meta.name)
//        )
//
//        bindOptions(to: binder, using: parser, meta: meta)
//    }
//
//    // swiftlint:disable large_tuple
//    /**
//     * Parses the included arguments.
//     * - Returns:
//     * The chosen command (if exists), app options, and the parsing result.
//     */
//    func parse(arguments: [String]) throws -> (String?, App.Options, ParsingResult) {
//        let result = try parser.parse(arguments)
//
//        var options: App.Options = .blank
//
//        try binder.fill(parseResult: result, into: &options)
//
//        return (result.subparser(parser), options, result)
//    }
//    // swiftlint:enable large_tuple
//
//    /// Prints the usage to standard out.
//    func printUsage() {
//        parser.printUsage(on: stdoutStream)
//    }
//
//    /// Registers a given command.
//    func register(command: (ArgumentParser, Binder) -> Command) {
//        self.commands.append(command(parser, binder))
//    }
//
//    /// Runs a given command.
//    func runCommand(named name: String, with result: ParsingResult, app: App, env: Environment) throws {
//        guard let command = commands.first(where: { $0.name == name }) else {
//            return
//        }
//
//        return try command.run(with: result, app: app, env: env)
//    }
//
//    private func bindOptions(to binder: Binder, using parser: ArgumentParser, meta: App.Meta) {
//        binder.bind(option: parser.add(
//            option: "--version",
//            shortName: "-V",
//            kind: Bool.self,
//            usage: Strings.App.Options.showVersion(appName: meta.name)
//        )) { $0.shouldPrintVersion = $1 }
//
//        binder.bind(option: parser.add(
//            option: "--config",
//            kind: String.self,
//            usage: Strings.App.Options.configPath
//        )) { $0.configPath = $1 }
//    }
//}
