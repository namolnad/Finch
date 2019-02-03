//
//  Git.swift
//  DiffFormatterApp.swift
//
//  Created by Dan Loman on 12/29/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Basic
import DiffFormatterCore
import DiffFormatterUtilities

struct Git {
    let configuration: Configuration
    let env: Environment
}

extension Git {
    func log(oldVersion: Version, newVersion: Version) throws -> String {
        guard !isTest else {
            return ""
        }

        let executableArgs: [String] = [
            "\(gitExecutablePath)",
            "--git-dir",
            "\(configuration.projectDir)",
        ]

        return try Shell.run(
            args: executableArgs + gitLogArguments(
                oldVersion: oldVersion.description,
                newVersion: newVersion.description
            ),
            env: env
        )
    }

    func fetch() throws {
        let args: [String] = [
            "\(gitExecutablePath)",
            "--git-dir",
            "\(configuration.projectDir)",
            "fetch"
        ]

        _ = try Shell.run(args: args, env: env)
    }

    private var gitExecutablePath: String {
        if let path = configuration.gitExecutablePath {
            return path
        }
        guard let path = Process.findExecutable("git")?.asString else {
            return ""
        }

        return path
    }

    private func gitLogArguments(oldVersion: String, newVersion: String) -> [String] {
        return [
            "log",
            "--left-right",
            "--graph",
            "--cherry-pick",
            "--oneline",
            "--format=format:&&&%H&&& - @@@%s@@@###%ae###",
            "--date=short",
            "\(configuration.gitBranchPrefix)\(oldVersion)...\(configuration.gitBranchPrefix)\(newVersion)"
        ]
    }
}
