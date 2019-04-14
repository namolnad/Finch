//
//  CompareCommand.swift
//  FinchApp
//
//  Created by Dan Loman on 1/29/19.
//

import Commandant
import Curry
import FinchUtilities
import Version

/// Command to compare two versions and generate the appropriate changelog.
final class CompareCommand: Command {

    typealias ClientError = AppError

    typealias Options = CompareOptions

    /// CompareCommand options received from the commandline.
    final class CompareOptions: App.Options, OptionsProtocol {
        typealias ClientError = AppError

        /// The versions for comparison.
        fileprivate(set) var versions: Versions

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

        /**
         * A set of tags required for commit presence in the final output.
         * Note: Not used for section assignment.
         */
        fileprivate(set) var requiredTags: Set<String>

        static func evaluate(_ m: CommandMode) -> Result<CompareCommand.Options, CommandantError<CompareOptions.ClientError>> {
            return curry(self.init)
                <*> m <| Option<String?>(key: App.Options.Key.configPath.rawValue, defaultValue: nil, usage: Strings.App.Options.configPath)
                <*> m <| Option<String?>(key: App.Options.Key.projectDir.rawValue, defaultValue: nil, usage: Strings.App.Options.projectDir)
                <*> m <| Switch(key: App.Options.Key.verbose.rawValue, usage: Strings.App.Options.verbose)
                <*> m <| Option<Versions>(key: "versions", defaultValue: .null, usage: Strings.Compare.Options.versions)
                <*> m <| Option<String?>(key: "build-number", defaultValue: nil, usage: Strings.Compare.Options.buildNumber)
                <*> m <| Option<String?>(key: "git-log", defaultValue: nil, usage: Strings.Compare.Options.gitLog)
                <*> m <| Switch(key: "normalize-tags", usage: Strings.Compare.Options.normalizeTags)
                <*> m <| Switch(key: "no-fetch", usage: Strings.Compare.Options.noFetch)
                <*> m <| Switch(key: "no-show-version", usage: Strings.Compare.Options.noShowVersion)
                <*> m <| Option<String?>(key: "release-manager", defaultValue: nil, usage: Strings.Compare.Options.releaseManager)
                <*> m <| Option<[String]>(key: "required-tags", defaultValue: [], usage: Strings.Compare.Options.requiredTags)
        }

        init(
            configPath: String?,
            projectDir: String?,
            verbose: Bool,
            versions: Versions,
            buildNumber: String?,
            gitLog: String?,
            normalizeTags: Bool,
            noFetch: Bool,
            noShowVersion: Bool,
            releaseManager: String?,
            requiredTags: [String]) {
            self.versions = versions
            self.buildNumber = buildNumber
            self.gitLog = gitLog
            self.normalizeTags = normalizeTags
            self.noFetch = noFetch
            self.noShowVersion = noShowVersion
            self.releaseManager = releaseManager
            self.requiredTags = Set(requiredTags)

            super.init(configPath: configPath, projectDir: projectDir, verbose: verbose)
        }
    }

    let environment: Environment

    let function: String = Strings.Compare.commandOverview

    let meta: App.Meta

    let output: OutputType

    /// The command's name.
    let verb: String = Strings.Compare.commandName

    private let model: ChangeLogModelType

    /// :nodoc:
    init(env: Environment, meta: App.Meta, output: OutputType, model: ChangeLogModelType = ChangeLogModel()) {
        self.environment = env
        self.meta = meta
        self.output = output
        self.model = model
    }

    func run(options: Options, app: App, env: Environment) -> Result<(), ClientError> {
        do {
            if [options.versions.new, options.versions.old].allSatisfy({ $0 == .null }) {
                let versions = try model.versions(app: app, env: env)
                options.versions = .init(old: versions.old, new: versions.new)
            }

            let result = try model.changeLog(
                options: options,
                app: app,
                env: env
            )

            app.print(result)
        } catch {
            return .failure(.wrapped(error))
        }

        return .success(())
    }

    fileprivate static var blank: CompareOptions {
        return .init(
            configPath: nil,
            projectDir: nil,
            verbose: false,
            versions: .null,
            buildNumber: nil,
            gitLog: nil,
            normalizeTags: false,
            noFetch: false,
            noShowVersion: false,
            releaseManager: nil,
            requiredTags: []
        )
    }
}

struct Versions: ArgumentProtocol {
    let old: Version

    let new: Version

    static var null: Versions = .init(old: .null, new: .null)

    public static var name: String = "versions"

    public static func from(string: String) -> Versions? {
        guard let versions = try? VersionsResolver().versions(from: string) else {
            return nil
        }

        return Versions(old: versions.old, new: versions.new)
    }
}
