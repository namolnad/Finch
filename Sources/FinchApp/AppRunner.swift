import FinchUtilities
import Foundation
import SwiftCLI

/**
 * A class responsible for running the app. Internally registers
 * all commands. Selects and runs the proper command.
 */
public class AppRunner {
    private let cli: CLI

    /// :nodoc:
    public init(environment: Environment, meta: App.Meta, output: OutputType = Output.instance) {
        self.cli = .init(
            name: meta.name.lowercased(),
            version: "\(meta.version.description) (\(meta.buildNumber))",
            description: Strings.App.overview
        )

        cli.globalOptions = BaseCommand.globalOptions

        let appGenerator: AppGenerator = { configPath, projectDir, verbose in
            let config = Configurator(
                configPath: configPath,
                projectDir: projectDir,
                meta: meta,
                environment: environment,
                output: output
            ).configuration

            let app: App = .init(
                configuration: config,
                environment: environment,
                meta: meta,
                verbose: verbose,
                output: output
            )

            return app
        }

        cli.commands = [
            CompareCommand(appGenerator: appGenerator),
            ConfigGroup(children: [
                ConfigExampleCommand(appGenerator: appGenerator)
            ])
        ]
    }

    /// Runs the app
    @discardableResult
    public func run(with arguments: [String]) -> Int32 {
        cli.go(with: Array(arguments.dropFirst()))
    }
}
