import ArgumentParser
import FinchCore
import FinchUtilities
import Yams

/// Command group for configuration-centric operations.
struct ConfigCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: Strings.Config.commandName,
        abstract: Strings.Config.commandOverview,
        subcommands: [ConfigExampleCommand.self]
    )

    /// Invoked bare, the group has nothing to do but describe itself.
    func run() throws {
        throw CleanExit.helpRequest(self)
    }
}

struct ConfigExampleCommand: AppCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: Strings.Config.Example.commandName,
        abstract: Strings.Config.Example.commandOverview
    )

    @OptionGroup var globalOptions: GlobalOptions

    func run(with app: App) throws {
        let exampleConfig: Configuration = .example(projectDir: app.configuration.projectDir)

        try app.print(YAMLEncoder().encode(exampleConfig))
    }
}
