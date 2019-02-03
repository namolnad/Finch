//
//  Executable.swift
//  DiffFormatterUtilities
//
//  Created by Dan Loman on 2/3/19.
//

import class Basic.Process
import Foundation

public enum Executable: String {
    case git
    case grep
    case sed
    case sh
    case sort
    case tail
    case tr

    public func getPath() throws -> String {
        guard let path = Process.findExecutable(self.rawValue) else {
            throw Error.notFound(self.rawValue)
        }

        return path.asString
    }

    public enum Error: LocalizedError {
        case notFound(String)

        public var failureReason: String? {
            switch self {
            case .notFound(let exec):
                return .localizedStringWithFormat(
                    NSLocalizedString(
                        "Executable %@ not found on PATH",
                        comment: "Error message when executable not found on path"
                    ),
                    exec
                )
            }
        }
    }
}
