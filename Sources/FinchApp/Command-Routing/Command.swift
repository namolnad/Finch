//
//  Command.swift
//  FinchApp
//
//  Created by Dan Loman on 1/29/19.
//

import Commandant
import FinchUtilities
#if !swift(>=5.0)
import Result
#endif

///// :nodoc:
public typealias Environment = [String: String]

protocol Command: CommandProtocol where Options: App.Options {

    var environment: Environment { get }

    var meta: App.Meta { get }

    var output: OutputType { get }

    func run(options: Options, app: App, env: Environment) -> Result<(), ClientError>
}

extension Command {
    /// Should NOT be implemented by types conforming to Command.
    func run(_ options: Options) -> Result<(), ClientError> {
        let config = Configurator(
            options: options,
            meta: meta,
            environment: environment,
            output: output
            ).configuration

        let app: App = .init(
            configuration: config,
            meta: meta,
            options: options,
            output: output
        )

        return run(options: options, app: app, env: environment)
    }
}
