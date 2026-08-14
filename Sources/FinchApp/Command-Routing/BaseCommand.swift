import ArgumentParser
import FinchCore
import FinchUtilities

/// :nodoc:
public typealias Environment = [String: String]

/// Declared here rather than in FinchCore, which has no business importing an argument parser
extension CommitStyle: ExpressibleByArgument {}

/// The options accepted by every command which runs against an `App`.
struct GlobalOptions: ParsableArguments {
    @Flag(name: [.customShort("v"), .long], help: .init(Strings.App.Options.verbose))
    var verbose: Bool = false

    @Option(name: [.customShort("c"), .long], help: .init(Strings.App.Options.configPath))
    var config: String?

    @Option(name: .long, help: .init(Strings.App.Options.commitStyle))
    var commitStyle: CommitStyle?

    @Option(name: .long, help: .init(Strings.App.Options.projectDir))
    var projectDir: String?
}

/**
 * A command which runs against an `App`.
 *
 * The environment and meta-information an `App` is built from belong to the
 * process rather than to the parsed arguments, so `AppRunner` builds the app
 * and hands it to the command — a command never reaches for it itself.
 */
protocol AppCommand: ParsableCommand {
    var globalOptions: GlobalOptions { get }

    /// **[Required]** The body of the command.
    func run(with app: App) throws
}

extension AppCommand {
    /**
     * Unused: every command is dispatched by `AppRunner` through
     * `run(with:)`, which is the only path with an `App` to run against.
     */
    func run() throws {
        throw ValidationError(Strings.App.Error.noAppContext)
    }
}
