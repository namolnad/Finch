//
//  Shell.swift
//  DiffFormatterApp
//
//  Created by Dan Loman on 2/3/19.
//

import Basic

public struct Shell {
    public enum Error: Swift.Error {
        case emptyArguments
        case emptyResult
    }

    public static func run(args: [String], env: Environment) throws -> String {
        guard !args.isEmpty else {
            throw Error.emptyArguments
        }

        let process: Process = .init(
            arguments: args,
            environment: env
        )

        try process.launch()
        try process.waitUntilExit()

        if let result = process.result {
            return try result.utf8Output()
        } else {
            throw Error.emptyResult
        }
    }
}
