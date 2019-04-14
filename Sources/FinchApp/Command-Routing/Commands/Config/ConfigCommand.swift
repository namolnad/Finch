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

    typealias ClientError = AppError

    typealias Options = ConfigOptions

    /// ConfigCommand options received from the commandline.
    final class ConfigOptions: App.Options, OptionsProtocol {
        typealias ClientError = AppError

        /// Config command mode (subcommand)
        let mode: Mode

        static func evaluate(_ m: CommandMode) -> Result<ConfigCommand.Options, CommandantError<ConfigOptions.ClientError>> {
            return curry(self.init)
                <*> m <| Option<String?>(key: App.Options.Key.configPath.rawValue, defaultValue: nil, usage: Strings.App.Options.configPath)
                <*> m <| Option<String?>(key: App.Options.Key.projectDir.rawValue, defaultValue: nil, usage: Strings.App.Options.projectDir)
                <*> m <| Switch(key: App.Options.Key.verbose.rawValue, usage: Strings.App.Options.verbose)
                <*> m <| Argument(usage: "\(Mode.allCases.filter { $0 != .unknown }.reduce("") { "\($0)\n[\($1.function)]\n\t\($1.usage)\n" })", usageParameter: "subcommand")
        }

        init(
            configPath: String?,
            projectDir: String?,
            verbose: Bool,
            mode: String) {
            self.mode = Mode(rawValue: mode) ?? .unknown

            super.init(configPath: configPath, projectDir: projectDir, verbose: verbose)
        }
    }

    enum Mode: String, CaseIterable {
        /// Print an example config.
        case showExample = "show-example"
        case unknown

        fileprivate var function: String {
            switch self {
            case .showExample:
                return rawValue
            case .unknown:
                return ""
            }
        }

        fileprivate var usage: String {
            switch self {
            case .showExample:
                return Strings.Config.Options.showExample
            case .unknown:
                return ""
            }
        }
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
    func run(options: Options, app: App, env: Environment) -> Result<(), ClientError> {
        switch options.mode {
        case .showExample:
            let exampleConfig: Configuration = .example(projectDir: app.configuration.projectDir)

            do {
                app.print(try YAMLEncoder().encode(exampleConfig))
            } catch {
                return .failure(.wrapped(error))
            }
            return .success(())
        case .unknown:
            return .failure(.unsupportedConfigMode)
        }
    }

    fileprivate static var blank: ConfigOptions {
        return .init(
            configPath: nil,
            projectDir: nil,
            verbose: false,
            mode: ""
        )
    }
}
