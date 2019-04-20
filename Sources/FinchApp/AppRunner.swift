//
//  AppRunner.swift
//  FinchApp
//
//  Created by Dan Loman on 1/29/19.
//

import Commandant
import FinchUtilities
import Foundation

enum AppError: LocalizedError {
    /// Unsupported mode (subcommand) for config command
    case unsupportedConfigMode

    /// Wraps error types which should be propogated
    case wrapped(Error)

    var localizedDescription: String {
        switch self {
        case .unsupportedConfigMode:
            return Strings.Error.unsupportedConfigMode
        case let .wrapped(error):
            return error.localizedDescription
        }

    }
}

/**
 * A class responsible for running the app. Internally registers
 * all commands. Selects and runs the proper command.
 */
public class AppRunner {
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
