//
//  Shell.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Basic
import protocol Foundation.LocalizedError

public struct Shell {
    public enum Error: LocalizedError {
        case emptyArguments
        case emptyResult
    }

    private let env: [String: String]
    private let verbose: Bool

    public init(env: [String: String], verbose: Bool = false) {
        self.env = env
        self.verbose = verbose
    }

    public func run(args: [String]) throws -> String {
        guard !args.isEmpty else {
            throw Error.emptyArguments
        }

        let process: Process = .init(
            arguments: [try Executable.sh.getPath(), "-c"] + [args.joined(separator: " ")],
            environment: env,
            verbose: verbose
        )

        try process.launch()
        try process.waitUntilExit()

        guard let result = process.result else {
            throw Error.emptyResult
        }

        return try result.utf8Output()
    }
}
