//
//  CompareCommand.swift
//  FinchApp
//
//  Created by Dan Loman on 1/29/19.
//

import FinchUtilities
import SwiftCLI
import Version

/// Command to compare two versions and generate the appropriate changelog.
final class CompareCommand: BaseCommand {
    struct Options {
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
    }

    let versions: Key<Versions> = .init("--versions", description: Strings.Compare.Options.versions)
    let buildNumber: Key<String> = .init("--build-number", description: Strings.Compare.Options.buildNumber)
    let gitLog: Key<String> = .init("--git-log", description: Strings.Compare.Options.gitLog)
    let normalizeTags: Flag = .init("--normalize-tags", description: Strings.Compare.Options.normalizeTags)
    let noFetch: Flag = .init("--no-fetch", description: Strings.Compare.Options.noFetch)
    let noShowVersion: Flag = .init("--no-show-version", description: Strings.Compare.Options.noShowVersion)
    let releaseManager: Key<String> = .init("--release-manager", description: Strings.Compare.Options.releaseManager)
    let requiredTags: Key<[String]> = .init("--required-tags", description: Strings.Compare.Options.requiredTags)

    override var shortDescription: String { return Strings.Compare.commandOverview }

    override var longDescription: String { return Strings.Compare.commandOverview }

    /// The command's name.
    override var name: String { return Strings.Compare.commandName }

    private let model: ChangeLogModelType

    /// :nodoc:
    init(appGenerator: @escaping AppGenerator, model: ChangeLogModelType = ChangeLogModel()) {
        self.model = model

        super.init(appGenerator: appGenerator)
    }

    override func run(with app: App) throws {
        let versions: Versions
        if let value = self.versions.value {
            versions = value
        } else {
            let derivedVersions = try model.versions(app: app)
            versions = .init(old: derivedVersions.old, new: derivedVersions.new)
        }

        let options: Options = .init(
            versions: versions,
            buildNumber: buildNumber.value,
            gitLog: gitLog.value,
            normalizeTags: normalizeTags.value,
            noFetch: noFetch.value,
            noShowVersion: noShowVersion.value,
            releaseManager: releaseManager.value,
            requiredTags: Set(requiredTags.value ?? [])
        )

        let result = try model.changeLog(
            options: options,
            app: app
        )

        app.print(result)
    }
}

extension Array: ConvertibleFromString where Element == String {
    public static func convert(from: String) -> [String]? {
        return from.components(separatedBy: " ")
    }
}
