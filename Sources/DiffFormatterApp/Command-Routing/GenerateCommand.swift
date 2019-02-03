//
//  GenerateCommand.swift
//  DiffFormatterApp
//
//  Created by Dan Loman on 1/29/19.
//

import DiffFormatterUtilities
import Utility

final class GenerateCommand: Command {
    struct Options {
        fileprivate(set) var versions: (old: Version, new: Version)
        fileprivate(set) var buildNumber: Int?
        fileprivate(set) var gitLog: String?
        fileprivate(set) var noFetch: Bool
        fileprivate(set) var noShowVersion: Bool
        fileprivate(set) var releaseManager: String?
        fileprivate(set) var toPasteBoard: Bool
    }

    private typealias Binder = ArgumentBinder<Options>

    let name: String = "gen"

    private let binder: Binder = .init()

    private let subparser: ArgumentParser

    init(meta: App.Meta, parser: ArgumentParser) {
        self.subparser = parser.add(
            subparser: name,
            overview: "Generates the changelog"
        )

        bindOptions(to: binder, meta: meta)
    }

    func run(with result: ParsingResult, app: App, env: Environment) throws {
        var options: Options = .blank

        try binder.fill(parseResult: result, into: &options)

        if [options.versions.new, options.versions.old].allSatisfy({ $0 == .init(0, 0, 0) }) {
            options.versions = try VersionResolver().resolve(app: app, env: env)
        }

        let outputGenerator: OutputGenerator = try .init(
            options: options,
            app: app,
            env: env
        )

        let result = outputGenerator.generateOutput()

        if options.toPasteBoard {
            app.print("Copying output to pasteboard", kind: .info)
            pbCopy(text: result)
        }

        app.print(result)
    }

    @discardableResult
    func bindingGlobalOptions(to binder: CommandRegistry.Binder) -> GenerateCommand {
        binder.bind(option: subparser.add(
            option: "--verbose",
            shortName: "-v",
            kind: Bool.self,
            usage: "Run command with verbose output"
        )) { $0.verbose = $1 }

        binder.bind(option: subparser.add(
            option: "--project-dir",
            kind: PathArgument.self,
            usage: "Path to project if command is run from separate directory"
        )) { $0.projectDir = $1.path.asString }

        return self
    }

    // swiftlint:disable function_body_length line_length
    private func bindOptions(to binder: Binder, meta: App.Meta) {
        binder.bind(option: subparser.add(
            option: "--versions",
            kind: [Version].self,
            usage: "<version_1> <version_2>"
        )) { options, versions in
            guard versions.count == 2, let firstVersion = versions.first, let secondVersion = versions.last else {
                throw ArgumentParserError.invalidValue(
                    argument: "versions",
                    error: .custom("Must receive 2 versions to properly generate changelog")
                )
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
            usage: "Build number string to be included in version header. Takes precedence over build number command in config. e.g. `6.19.1 (6258)`"
        )) { $0.buildNumber = $1 }

        binder.bind(option: subparser.add(
            option: "--git-log",
            kind: String.self,
            usage: "Pass in the git-log string directly vs having \(meta.name) generate it. See README for details"
        )) { $0.gitLog = $1 }

        binder.bind(option: subparser.add(
            option: "--no-fetch",
            kind: Bool.self,
            usage: "Don't fetch origin before auto-generating log"
        )) { $0.noFetch = $1 }

        binder.bind(option: subparser.add(
            option: "--no-show-version",
            kind: Bool.self,
            usage: "The ability to hide the version header"
        )) { $0.noShowVersion = $1 }

        binder.bind(option: subparser.add(
            option: "--release-manager",
            kind: String.self,
            usage: "The release manager's email. e.g. `--release-manager=$(git config --get user.email)`"
        )) { $0.releaseManager = $1 }

        binder.bind(option: subparser.add(
            option: "--to-pasteboard",
            kind: Bool.self,
            usage: "Copy output to pasteboard in addition to stdout"
        )) { $0.toPasteBoard = $1 }
    }
    // swiftlint:enable function_body_length line_length
}

extension GenerateCommand.Options {
    fileprivate static let blank: GenerateCommand.Options = .init(
        versions: (.init(0, 0, 0), .init(0, 0, 0)),
        buildNumber: nil,
        gitLog: nil,
        noFetch: false,
        noShowVersion: false,
        releaseManager: nil,
        toPasteBoard: false
    )
}
