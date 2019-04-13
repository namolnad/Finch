//
//  Strings.swift
//  FinchUtilities
//
//  Created by Dan Loman on 2/23/19.
//

enum Strings {
    enum Error {
        enum Exec {
            static func notFound(_ exec: String) -> String {
                return "Executable \(exec) not found on PATH"
            }

            static let noPathVariable: String = "No PATH variable found in Environment"
        }

        enum Shell {
            static let emptyArguments: String = "Empty arguments passed to subprocess. Please report this issue."

            static func emptyResult(args: String) -> String {
                return "Empty result from subprocess: \(args). Consider reporting this issue."
            }

            static func subprocessNonZeroExit(code: Int32, message: String) -> String {
                return "Internal process exited with non-zero status: \(code) \(message)"
            }
        }
    }
}
