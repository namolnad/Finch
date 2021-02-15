//
//  Shell.swift
//  Finch
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

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

        let pipe = Pipe()
        let process = Process()
        let path = try executable(.sh)
        process.arguments = ["-c", args.joined(separator: " ")]
        process.environment = env
        process.standardOutput = pipe

        let fileHandle = pipe.fileHandleForReading

        try process.run(at: path)
        process.waitUntilExit()

        let code = process.terminationStatus

        switch code {
        case 0:
            guard let string = output(fileHandle: fileHandle) else {
                throw Error.emptyResult(args: args.joined(separator: " "))
            }

            return string
        default:
            throw Error.subprocessNonZeroExit(code: code, message: output(fileHandle: fileHandle) ?? "")
        }
    }

    private func output(fileHandle: FileHandle) -> String? {
        String(data: fileHandle.readDataToEndOfFile(), encoding: .utf8)
    }
}

extension Process {
    fileprivate func run(at path: String) throws {
        #if os(macOS)
        if #available(macOS 10.13, *) {
            executableURL = URL(fileURLWithPath: path)
            try run()
            return
        }
        #endif

        launchPath = path
        launch()
    }
}
