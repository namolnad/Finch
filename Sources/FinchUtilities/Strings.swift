//
//  Strings.swift
//  FinchUtilities
//
//  Created by Dan Loman on 2/23/19.
//

import Foundation

enum Strings {
    enum Error {
        enum Exec {
            static func notFound(_ exec: String) -> String {
                return .localizedStringWithFormat(
                    NSLocalizedString(
                        "Executable %@ not found on PATH",
                        comment: "Error message when executable not found on path"
                    ),
                    exec
                )
            }
        }

        enum Shell {
            static let emptyArguments: String = NSLocalizedString(
                "Empty arguments passed to subprocess. Please report this issue.",
                comment: "Error message indicating empty arguments passed to subprocess"
            )

            static func emptyResult(args: String) -> String {
                return .localizedStringWithFormat(
                    NSLocalizedString(
                        "Empty result from subprocess: %@. Consider reporting this issue.",
                        comment: "Error message indicating empty subprocess result"
                    ),
                    args
                )
            }

            static func subprocessNonZeroExit(code: Int32, message: String) -> String {
                return .localizedStringWithFormat(
                    NSLocalizedString(
                        "Internal process exited with non-zero status: %@ %@",
                        comment: "Error message asking user to report the error they've encountered"
                    ),
                    code,
                    message
                )
            }
        }
    }
}
