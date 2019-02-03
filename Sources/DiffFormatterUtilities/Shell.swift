//
//  Shell.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Basic

public struct Shell {
    public enum Error: Swift.Error {
        case emptyArguments
        case emptyResult
    }

    public static func run(args: [String], env: [String: String]) throws -> String {
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
