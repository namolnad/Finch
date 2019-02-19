//
//  CompareCommand.swift
//  FinchApp
//
//  Created by Dan Loman on 1/29/19.
//

import FinchUtilities
import Foundation
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
    let name: String = "compare"

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
            overview: "Compares two versions and generates a formatted changelog"
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
            app.print("Copying output to pasteboard", kind: .info)
            pbCopy(text: result)
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
            usage: "<version_1> <version_2> Use explicit versions for the changelog instead of auto-resolving"
        )) { options, versions in
            guard versions.count == 2, let firstVersion = versions.first, let secondVersion = versions.last else {
                throw ArgumentParserError.invalidValue(
                    argument: "versions",
                    error: .custom("Must receive 2 versions to properly compare and generate changelog")
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
            usage: "Build number string to be included in version header. Takes precedence over build number command in config. e.g. `6.19.1 (6258)`"
        )) { $0.buildNumber = $1 }

        binder.bind(option: subparser.add(
            option: "--git-log",
            kind: String.self,
            usage: .localizedStringWithFormat(
                NSLocalizedString(
                    "Pass in the git-log string directly vs having %@ generate it. See README for details",
                    comment: "Git log option description"
                ), meta.name
            )
        )) { $0.gitLog = $1 }

        binder.bind(option: subparser.add(
            option: "--normalize-tags",
            kind: Bool.self,
            usage: "Normalize all commit tags by lowercasing prior to running comparison"
        )) { $0.normalizeTags = $1 }

        binder.bind(option: subparser.add(
            option: "--no-fetch",
            kind: Bool.self,
            usage: "Don't fetch origin before auto-generating log"
        )) { $0.noFetch = $1 }

        binder.bind(option: subparser.add(
            option: "--no-show-version",
            kind: Bool.self,
            usage: "Hides version header"
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
