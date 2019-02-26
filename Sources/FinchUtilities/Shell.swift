//
//  Shell.swift
//  Finch
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Basic
import Foundation

public struct Shell {
    public enum Error: LocalizedError {
        case emptyArguments
        case emptyResult(args: String)
        case subprocessNonZeroExit(code: Int32, message: String)

        public var failureReason: String? {
            switch self {
            case .emptyArguments:
                return Strings.Error.Shell.emptyArguments
            case .emptyResult(args: let args):
                return Strings.Error.Shell.emptyResult(args: args)
            case .subprocessNonZeroExit(code: let code, message: let message):
                return Strings.Error.Shell.subprocessNonZeroExit(code: code, message: message)
            }
        }
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

        let process: Basic.Process = .init(
            arguments: [try executable(.sh), "-c"] + [args.joined(separator: " ")],
            environment: env,
            verbose: verbose
        )

        try process.launch()
        try process.waitUntilExit()

        guard let result = process.result else {
            throw Error.emptyResult(args: args.joined(separator: " "))
        }

        switch result.exitStatus {
        case .signalled(signal: let code), .terminated(code: let code):
            guard code == 0 else {
                throw Error.subprocessNonZeroExit(code: code, message: try result.utf8stderrOutput())
            }

            return try result.utf8Output()
        }
    }
}
