//
//  Command.swift
//  FinchApp
//
//  Created by Dan Loman on 1/29/19.
//

import Utility

/// :nodoc:
public typealias ParsingResult = ArgumentParser.Result

/// :nodoc:
public typealias Environment = [String: String]

/// Protocol describing a command.
protocol Command {
    /// Name of the command.
    var name: String { get }

    /**
     * Runs the command with the parsing result, app,
     * and current environment.
     */
    func run(with result: ParsingResult, app: App, env: Environment) throws

    /// Optional function to allow the command to bind to the main app options,
    func bindingGlobalOptions(to binder: ArgumentBinder<App.Options>) -> Self
}

/// :nodoc:
extension Command {
    func bindingGlobalOptions(to binder: ArgumentBinder<App.Options>) -> Self {
        return self
    }
}
