//
//  Command.swift
//  FinchApp
//
//  Created by Dan Loman on 1/29/19.
//

import Utility

public typealias ParsingResult = ArgumentParser.Result
public typealias Environment = [String: String]

protocol Command {
    var name: String { get }

    func run(with result: ParsingResult, app: App, env: Environment) throws
    func bindingGlobalOptions(to binder: ArgumentBinder<App.Options>) -> Self
}

extension Command {
    func bindingGlobalOptions(to binder: ArgumentBinder<App.Options>) -> Self {
        return self
    }
}
