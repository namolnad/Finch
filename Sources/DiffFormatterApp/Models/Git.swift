//
//  Git.swift
//  DiffFormatterApp.swift
//
//  Created by Dan Loman on 12/29/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import DiffFormatterCore
import DiffFormatterUtilities

struct Git {
    let configuration: Configuration
}

extension Git {
    func log(oldVersion: Version, newVersion: Version) -> String {
        guard !isTest else {
            return ""
        }

        return shell(
            executablePath: gitExecutablePath,
            arguments: gitLogArguments(
                oldVersion: oldVersion.description,
                newVersion: newVersion.description
            ),
            currentDirectoryPath: configuration.projectDir
        ) ?? ""
    }

    func fetch() {
        _ = shell(
            executablePath: gitExecutablePath,
            arguments: ["fetch"],
            currentDirectoryPath: configuration.projectDir
        )
    }

    private var gitExecutablePath: String {
        if let path = configuration.gitExecutablePath {
            return path
        }
        guard let path = shell(
            executablePath: "/bin/bash",
            arguments: ["-c", "which git"],
            currentDirectoryPath: configuration.projectDir
            ) else {
                return ""
        }

        return path.trimmingCharacters(in: .newlines)
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
