//
//  ConfigCommand.swift
//  FinchApp
//
//  Created by Dan Loman on 2/14/19.
//

import Commandant
import Curry
import FinchCore
import FinchUtilities
import Yams

/// Command to run configuration-centric operations.
struct ConfigCommand: Command {

    typealias ClientError = AppRunner.AppError

    typealias Options = ConfigOptions

    /// ConfigCommand options received from the commandline.
    final class ConfigOptions: App.Options, OptionsProtocol {
        typealias ClientError = AppRunner.AppError

        /// Print an example config.
        fileprivate(set) var shouldPrintExample: String

        static func evaluate(_ m: CommandMode) -> Result<ConfigOptions, CommandantError<ConfigOptions.ClientError>> {
            return curry(self.init)
                <*> m <| Option<String?>(key: App.Options.Key.configPath.rawValue, defaultValue: nil, usage: Strings.App.Options.configPath)
                <*> m <| Option<String?>(key: App.Options.Key.projectDir.rawValue, defaultValue: nil, usage: Strings.App.Options.projectDir)
                <*> m <| Switch(key: App.Options.Key.shouldPrintVersion.rawValue, usage: Strings.App.Options.showVersion)
                <*> m <| Switch(key: App.Options.Key.verbose.rawValue, usage: Strings.App.Options.verbose)
                <*> m <| Argument(usage: Strings.Config.Options.showExample)
        }

        init(
            configPath: String?,
            projectDir: String?,
            shouldPrintVersion: Bool,
            verbose: Bool,
            shouldPrintExample: String) {
            self.shouldPrintExample = shouldPrintExample

            super.init(configPath: configPath, projectDir: projectDir, shouldPrintVersion: shouldPrintVersion, verbose: verbose)
        }
    }

    private enum Mode: String {
        case showExample = "show-example"
    }

    let environment: Environment

    let function: String = Strings.Config.commandOverview

    let meta: App.Meta

    let output: OutputType

    /// ConfigCommand's name.
    let verb: String = Strings.Config.commandName

    init(env: Environment, meta: App.Meta, output: OutputType = Output.instance) {
        self.meta = meta
        self.environment = env
        self.output = output
    }

    /// Runs ConfigCommand with the given result, app, and env.
    func run(options: Options, app: App, env: Environment) -> Result<(), AppRunner.AppError> {
        if options.shouldPrintExample == ConfigCommand.Mode.showExample.rawValue {
            let exampleConfig: Configuration = .example(projectDir: app.configuration.projectDir)

            do {
                app.print(try YAMLEncoder().encode(exampleConfig))
            } catch {
                return .failure(.wrapped(error))
            }
        }

        return .success(())
    }

    fileprivate static var blank: ConfigOptions {
        return .init(
            configPath: nil,
            projectDir: nil,
            shouldPrintVersion: false,
            verbose: false,
            shouldPrintExample: ""
        )
    }
}
