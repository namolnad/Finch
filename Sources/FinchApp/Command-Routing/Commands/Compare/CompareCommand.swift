//
//  CompareCommand.swift
//  FinchApp
//
//  Created by Dan Loman on 1/29/19.
//

import FinchUtilities
import Utility

/// Command to compare two versions and generate the appropriate changelog.
final class CompareCommand: Command {
    /// CompareCommand options received from the commandline.
    struct Options {
        /// The versions for comparison.
        fileprivate(set) var versions: (old: Version, new: Version)

        /**
         * The build number to be included in the version header. Has
         * no effect if noShowVersion option is true.
         */
        fileprivate(set) var buildNumber: String?

        /**
         * The raw git log to be used rather than having Finch
         * generate/retrieve it.
         */
        fileprivate(set) var gitLog: String?

        /// Normalize the git commit tags by lowercasing them.
        fileprivate(set) var normalizeTags: Bool

        /**
         * Prevent Finch from performing the fetch operation on the
         * project repo. Has no effect if the gitLog option is set.
         */
        fileprivate(set) var noFetch: Bool

        /// Exclude the version header from the final output.
        fileprivate(set) var noShowVersion: Bool

        /**
         * Email address for the release manager. If included, a
         * special section will be included below the version header.
         */
        fileprivate(set) var releaseManager: String?

        /// Copy the final output to the system pasteboard.
        fileprivate(set) var toPasteBoard: Bool
    }

    private typealias Binder = ArgumentBinder<Options>

    /// The command's name.
    let name: String = Strings.Compare.commandName

    private let binder: Binder = .init()

    private let model: ChangeLogModelType

    private let subparser: ArgumentParser

    /// :nodoc:
    init(
        meta: App.Meta,
        parser: ArgumentParser,
        model: ChangeLogModelType = ChangeLogModel()
        ) {
        self.model = model
        self.subparser = parser.add(
            subparser: name,
            overview: Strings.Compare.commandOverview
        )

        bindOptions(to: binder, meta: meta)
    }

    /// Runs CompareCommand with the given result, app, and env.
    func run(with result: ParsingResult, app: App, env: Environment) throws {
        var options: Options = .blank

        try binder.fill(parseResult: result, into: &options)

        if [options.versions.new, options.versions.old].allSatisfy({ $0 == .init(0, 0, 0) }) {
            options.versions = try model.versions(app: app, env: env)
        }

        let result = try model.changeLog(
            options: options,
            app: app,
            env: env
        )

        if options.toPasteBoard {
            #if os(macOS)
            app.print(Strings.Compare.Progress.toPasteboard, kind: .info)
            pbCopy(text: result)
            #endif
        }

        app.print(result)
    }

    /**
     * Binds special options received after the `compare` command
     * to the global app options.
     *
     * #### Options for global binding
     * - `--verbose`
     * - `--project-dir`
     */
    @discardableResult
    func bindingGlobalOptions(to binder: CommandRegistry.Binder) -> CompareCommand {
        binder.bind(option: subparser.add(
            option: "--verbose",
            shortName: "-v",
            kind: Bool.self,
            usage: Strings.App.Options.verbose
        )) { $0.verbose = $1 }

        binder.bind(option: subparser.add(
            option: "--project-dir",
            kind: PathArgument.self,
            usage: Strings.App.Options.projectDir
        )) { $0.projectDir = $1.path.asString }

        return self
    }

    // swiftlint:disable function_body_length
    private func bindOptions(to binder: Binder, meta: App.Meta) {
        binder.bind(option: subparser.add(
            option: "--versions",
            kind: [Version].self,
            usage: Strings.Compare.Options.versions
        )) { options, versions in
            guard versions.count == 2, let firstVersion = versions.first, let secondVersion = versions.last else {
                throw ArgumentParserError.invalidValue(
                    argument: "versions",
                    error: .custom(Strings.Compare.Error.versions)
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
            kind: String.self,
            usage: Strings.Compare.Options.buildNumber
        )) { $0.buildNumber = $1 }

        binder.bind(option: subparser.add(
            option: "--git-log",
            kind: String.self,
            usage: Strings.Compare.Options.gitLog(appName: meta.name)
        )) { $0.gitLog = $1 }

        binder.bind(option: subparser.add(
            option: "--normalize-tags",
            kind: Bool.self,
            usage: Strings.Compare.Options.normalizeTags
        )) { $0.normalizeTags = $1 }

        binder.bind(option: subparser.add(
            option: "--no-fetch",
            kind: Bool.self,
            usage: Strings.Compare.Options.noFetch
        )) { $0.noFetch = $1 }

        binder.bind(option: subparser.add(
            option: "--no-show-version",
            kind: Bool.self,
            usage: Strings.Compare.Options.noShowVersion
        )) { $0.noShowVersion = $1 }

        binder.bind(option: subparser.add(
            option: "--release-manager",
            kind: String.self,
            usage: Strings.Compare.Options.releaseManager
        )) { $0.releaseManager = $1 }

        #if os(macOS)
        binder.bind(option: subparser.add(
            option: "--to-pasteboard",
            kind: Bool.self,
            usage: Strings.Compare.Options.toPasteboard
        )) { $0.toPasteBoard = $1 }
        #endif
    }
    // swiftlint:enable function_body_length
}

extension CompareCommand.Options {
    fileprivate static let blank: CompareCommand.Options = .init(
        versions: (.init(0, 0, 0), .init(0, 0, 0)),
        buildNumber: nil,
        gitLog: nil,
        normalizeTags: false,
        noFetch: false,
        noShowVersion: false,
        releaseManager: nil,
        toPasteBoard: false
    )
}
