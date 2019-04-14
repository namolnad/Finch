//
//  AppRunner.swift
//  FinchApp
//
//  Created by Dan Loman on 1/29/19.
//

import Commandant
import FinchUtilities

/**
 * A class responsible for running the app. Internally registers
 * all commands. Selects and runs the proper command.
 */
public class AppRunner {
    enum AppError: Error {
        case notPrepared
        case unsupportedConfigMode
        case wrapped(Error)
    }

    private let output: OutputType

    private let registry: CommandRegistry<AppError> = .init()

    /// :nodoc:
    public init(environment: Environment, meta: App.Meta, output: OutputType = Output.instance) {
        self.output = output

        registry.register(CompareCommand(env: environment, meta: meta, output: output))
        registry.register(ConfigCommand(env: environment, meta: meta, output: output))
        registry.register(HelpCommand(registry: registry))
        registry.register(VersionCommand(env: environment, meta: meta, output: output))
    }

    /// Runs the app with the included arguments.
    public func run(arguments: [String]) {
        // Drop argument for Finch executable
        var args = arguments[1...]

        let command = args.removeFirst()

        guard let result = registry.run(command: command, arguments: Array(args)) else {
            return
        }

        switch result {
        case .success:
            break
        case .failure(let error):
            let message = error.localizedDescription

            output.print(
                Strings.Error.formatted(errorMessage: message),
                kind: .error,
                verbose: false
            )
        }
    }
}

// Abstract base class
//class BaseCommand: CommandProtocol {
//    typealias Options = App.Options
//
//    typealias ClientError = AppRunner.AppError
//
//    var verb: String {
//        fatalError("Not implemented")
//    }
//
//    var function: String {
//        fatalError("Not implemented")
//    }
//
//    private let environment: Environment
//
//    private let meta: App.Meta
//
//    private let output: OutputType
//
//    init(env: Environment, meta: App.Meta, output: OutputType) {
//        self.environment = env
//        self.meta = meta
//        self.output = output
//    }
//
//    /// Implemented by the base class. Should NOT be overidden
//    final func run(_ options: BaseCommand.Options) -> Result<(), AppRunner.AppError> {
//        let config = Configurator(
//            options: options,
//            meta: meta,
//            environment: environment,
//            output: output
//            ).configuration
//
//        let app: App = .init(
//            configuration: config,
//            meta: meta,
//            options: options,
//            output: output
//        )
//
//        return run(options: options, app: app, env: environment)
//    }
//
//    func run<T: Options>(options: T, app: App, env: Environment) -> Result<(), AppRunner.AppError> {
//        fatalError("Not implemented")
//    }
//}
