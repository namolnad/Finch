import ArgumentParser
import FinchUtilities
import Version

/// Command to compare two versions and generate the appropriate changelog.
struct CompareCommand: AppCommand {
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

        /**
         * If the new line char is encoded as a new line or as the combined "\n"
         * Note: Not used for section assignment.
         */
        fileprivate(set) var useNewlineChar: Bool
    }

    static let configuration: CommandConfiguration = .init(
        commandName: Strings.Compare.commandName,
        abstract: Strings.Compare.commandOverview
    )

    @OptionGroup var globalOptions: GlobalOptions

    @Option(help: .init(Strings.Compare.Options.versions))
    var versions: Versions?

    @Option(help: .init(Strings.Compare.Options.buildNumber))
    var buildNumber: String?

    @Option(help: .init(Strings.Compare.Options.gitLog))
    var gitLog: String?

    @Flag(help: .init(Strings.Compare.Options.normalizeTags))
    var normalizeTags: Bool = false

    @Flag(help: .init(Strings.Compare.Options.noFetch))
    var noFetch: Bool = false

    @Flag(help: .init(Strings.Compare.Options.noShowVersion))
    var noShowVersion: Bool = false

    @Option(help: .init(Strings.Compare.Options.releaseManager))
    var releaseManager: String?

    @Option(help: .init(Strings.Compare.Options.requiredTags))
    var requiredTags: Tags?

    @Flag(help: .init(Strings.Compare.Options.useNewlineChar))
    var useNewlineChar: Bool = false

    func run(with app: App) throws {
        // A stored property would have to satisfy the parser's Decodable conformance
        let model: ChangeLogModelType = ChangeLogModel()

        let versions: Versions
        if let value = self.versions {
            versions = value
        } else {
            let derivedVersions = try model.versions(app: app)
            versions = .init(old: derivedVersions.old, new: derivedVersions.new)
        }

        let options: Options = .init(
            versions: versions,
            buildNumber: buildNumber,
            gitLog: gitLog,
            normalizeTags: normalizeTags,
            noFetch: noFetch,
            noShowVersion: noShowVersion,
            releaseManager: releaseManager,
            requiredTags: requiredTags?.values ?? [],
            useNewlineChar: useNewlineChar
        )

        let result = try model.changeLog(
            options: options,
            app: app
        )

        app.print(result)
    }
}
