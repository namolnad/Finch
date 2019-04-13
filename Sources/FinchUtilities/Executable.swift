//
//  Executable.swift
//  FinchUtilities
//
//  Created by Dan Loman on 2/3/19.
//

import Foundation

public func executable(_ executable: Executable) throws -> String {
    guard let path = ExecutableFinder().executablePath(executable: executable) else {
        throw Error.notFound(rawValue)
    }

    return path
}

public enum Executable: String {
    // swiftlint:disable identifier_name
    case git
    case grep
    case sed
    case sh
    case sort
    case tail
    case tr
    // swiftlint:enable identifier_name

    public enum Error: LocalizedError {
        case notFound(String)

        public var failureReason: String? {
            switch self {
            case .notFound(let exec):
                return Strings.Error.Exec.notFound(exec)
            }
        }
    }
}

private struct ExecutableFinder {
    public enum Error: LocalizedError {
        case noPathVariable

        public var failureReason: String? {
            switch self {
            case .noPathVariable:
                return Strings.Error.Exec.noPathVariable
            }
        }
    }

    private let env: [String: String]

    init(env: [String: String] = ProcessInfo.processInfo) {
        self.env = env
    }

    private func getSearchPath() throws -> String {
        guard let path = ProcessInfo.processInfo.environment["PATH"] else {
            throw Error.noPathVariable
        }

        return path
    }

    private func searchPaths(from path: String) -> String {
        return path.split(separator: ":")
    }

    fileprivate func executablePath(executable: Executable) throws -> String? {
        return searchPaths(from: try getSearchPath())
            .map { $0 + "/" + executable.rawValue }
            .map(Path.init)
            .first { fileManager.isExecutableFile(atPath: $0.absolutePath) }?
            .map { $0.absolutePath }
    }

}

private struct Path {
    var absolutePath: String {
        guard let first = path.first, first == "/" else {
            return fileManager.currentDirectoryPath + "/" + path
        }

        return path
    }

    private let fileManager: FileManager

    private let path: String

    init(string: String, fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.path = string
    }
}
