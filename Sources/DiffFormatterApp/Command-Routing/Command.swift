//
//  Command.swift
//  DiffFormatterApp
//
//  Created by Dan Loman on 1/29/19.
//

import class Utility.ArgumentParser

public typealias ParsingResult = ArgumentParser.Result
public typealias Environment = [String: String]

protocol Command {
    var name: String { get }

    func run(with result: ParsingResult, app: App, env: Environment) throws
}
