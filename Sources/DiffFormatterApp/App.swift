//
//  App.swift
//  DiffFormatterApp
//
//  Created by Dan Loman on 1/13/19.
//  Copyright © 2019 DHL. All rights reserved.
//

//import Basic
import Utility
import DiffFormatterCore
import DiffFormatterRouting
import DiffFormatterTelemetry
import Foundation

let registry: CommandRegistry = .init()

extension App {
    public func run(processInfo: ProcessInfo) {
        let args: [String] = Array(processInfo
            .arguments
            .dropFirst() // Remove app name/command
        )
        let configurator = Configurator(processInfo: processInfo, argScheme: scheme)

        let parser = ArgumentParser(usage: "Changelog generation tool", overview: "\(name) is a flexible tool for generating well-formatted changelogs between application versions", seeAlso: "Visit https://github.com/namolnad/DiffFormatter for more information")

        let appVersion = parser.add(option: "--version", shortName: "-v", kind: Bool.self, usage: "Displays current \(name) version and build number", completion: nil)

        registry.register(command: ChangeLogCommand(app: self, parser: parser, configuration: configuration))

        do {
            let result = try parser.parse(args)
            print(result.description)
        } catch {
            print(error)
        }

//        if let appVersion = result.get(appVersion) {
//            print(appVersion)
//        } if let result.subparser()
//
//        let scheme = ArgumentScheme(arguments: args)
//
//
//        let router = ArgumentRouter(
//            app: self,
//            configuration: configurator.configuration,
//            handlers: [
//                ArgumentRouter.usageHandler,
//                ArgumentRouter.versionHandler,
//                ArgumentRouter.diffHandler
//            ]
//        )
//
//        if case .notHandled = router.route(argScheme: scheme) {
//            log.error("Unable to handle included arguments")
//        }
    }
}

import Basic

struct CommandRegistry {
    private var commands: [CommandType] = []

    mutating func register(command: CommandType) {
        commands.append(command)
    }

    mutating func register(commands: [CommandType]) {
        self.commands.append(contentsOf: commands)
    }

    func runCommand(named name: String, with result: ArgumentParser.Result) throws -> HandleResult {
        guard let command = commands.first(where: { $0.name == name }) else {
            return .notHandled
        }

        return try command.run(result)
    }
}

protocol CommandType {
    var name: String { get }
    var run: (ArgumentParser.Result) throws -> HandleResult { get }
}

struct Command<Options>: CommandType {
//    let binder: ArgumentBinder<Options> = .init()
    let name: String
    let run: (ArgumentParser.Result) throws -> HandleResult
}

struct ChangeLogCommand {
    private typealias Binder = ArgumentBinder<ChangeLogOptions>

    typealias Version = Utility.Version

    let command: Command<ChangeLogOptions>
//
//
//    private let subparser: ArgumentParser
//
//    private let versions: PositionalArgument<[Version]>
//
//    private let buildNumber: OptionArgument<Int>
//
//    private let gitLog: OptionArgument<String>
//
//    private let noFetch: OptionArgument<Bool>
//
//    private let projectDir: OptionArgument<PathArgument>
//
//    private let releaseManager: OptionArgument<String>

    init(app: App, parser: ArgumentParser, configuration: Configuration) {
        let binder: ArgumentBinder<ChangeLogOptions> = .init()

        let buildNumberCommand: (Version, String) throws -> Int? = { newVersion, projectDir in
            guard let args = configuration.buildNumberCommandArgs, !args.isEmpty else {
                return nil
            }

            let process = Basic.Process(
                arguments: args,
                environment: [
                    "NEW_VERSION": "\(newVersion)",
                    "PROJECT_DIR": "\(projectDir)"
                ],
                redirectOutput: false
            )

            try process.launch()
            try process.waitUntilExit()

            if let result = process.result {
                return Int(try result.utf8Output())
            } else {
                return nil
            }
        }

        self.command = .init(name: "generate") { result in
            var options: ChangeLogOptions = .blank
            try binder.fill(parseResult: result, into: &options)

            if options.buildNumber == nil {
                options.buildNumber = try buildNumberCommand(options.versions.new, options.projectDir)
            }

            // Send options to diff/log handler

            return .handled
        }

        bindOptions(
            to: binder,
            using: parser.add(subparser: command.name, overview: "Generates the changelog"),
            app: app
        )
    }

    private func bindOptions(to binder: ArgumentBinder<ChangeLogOptions>, using subparser: ArgumentParser, app: App) {
        binder.bind(positional: subparser.add(
            positional: "generate",
            kind: [Version].self,
            usage: "<OLD_VERSION> <NEW_VERSION> must be the first arguments to this command"
        )) { options, versions in
            guard versions.count == 2, let firstVersion = versions.first, let secondVersion = versions.last else {
                throw ArgumentParserError.invalidValue(argument: "versions", error: .custom("Must receive 2 versions to properly generate changelog"))
            }
            if firstVersion < secondVersion {
                options.versions = (old: firstVersion, new: secondVersion)
            } else {
                options.versions = (old: secondVersion, new: firstVersion)
            }
        }

        binder.bind(option: subparser.add(
            option: "--build-number",
            kind: Int.self,
            usage: "Pass in the build number for the changelog"
        )) { $0.buildNumber = $1 }

        binder.bind(option: subparser.add(
            option: "--git-log",
            kind: String.self,
            usage: "Pass in the git-log string directly vs having \(app.name) generate it"
        )) { $0.gitLog = $1 }

        binder.bind(option: subparser.add(
            option: "--no-fetch",
            kind: Bool.self,
            usage: ""
        )) { $0.noFetch = $1 }

        binder.bind(option: subparser.add(
            option: "--no-show-version",
            kind: Bool.self,
            usage: ""
        )) { $0.noShowVersion = $1 }

        binder.bind(option: subparser.add(
            option: "--project-dir",
            kind: PathArgument.self,
            usage: ""
        )) { $0.projectDir = $1.path.asString }

        binder.bind(option: subparser.add(
            option: "--release-manager",
            kind: String.self,
            usage: ""
        )) { $0.releaseManager = $1 }
    }
}

struct ChangeLogOptions {
    typealias Version = Utility.Version

    fileprivate(set) var versions: (old: Version, new: Version)
    fileprivate(set) var buildNumber: Int?
    fileprivate(set) var gitLog: String?
    fileprivate(set) var noFetch: Bool
    fileprivate(set) var noShowVersion: Bool
    fileprivate(set) var projectDir: String
    fileprivate(set) var releaseManager: String?
}

extension ChangeLogOptions {
    fileprivate static let blank: ChangeLogOptions = .init(
        versions: (.init(0, 0, 0), .init(0, 0, 0)),
        buildNumber: nil,
        gitLog: nil,
        noFetch: false,
        noShowVersion: false,
        projectDir: "",
        releaseManager: nil
    )
}

extension Utility.Version: ArgumentKind {
    public static var completion: ShellCompletion {
        return .none
    }

    public init(argument: String) throws {
        guard let version = Version(string: argument) else {
            throw ArgumentConversionError.typeMismatch(value: argument, expectedType: Version.self)
        }

        self = version
    }
}
