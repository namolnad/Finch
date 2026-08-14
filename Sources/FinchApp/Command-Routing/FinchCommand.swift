import ArgumentParser

/// The root command, under which every other command is nested.
struct FinchCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: Strings.App.commandName,
        abstract: Strings.App.overview,
        discussion: Strings.App.seeAlso,
        subcommands: [
            CompareCommand.self,
            ConfigCommand.self,
            VersionCommand.self
        ]
    )

    /// Invoked bare, the root command has nothing to do but describe itself.
    func run() throws {
        throw CleanExit.helpRequest(self)
    }
}

/// Prints the app's version and build number.
struct VersionCommand: AppCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: Strings.App.Version.commandName,
        abstract: Strings.App.Options.showVersion
    )

    @OptionGroup var globalOptions: GlobalOptions

    func run(with app: App) throws {
        app.print(app.meta.versionDescription)
    }
}
