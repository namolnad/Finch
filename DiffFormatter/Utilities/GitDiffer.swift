//
//  GitDiffer.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct GitDiffer {
    private let configuration: Configuration
    private let projectDir: String
    private let oldVersion: String
    private let newVersion: String

    init(configuration: Configuration, projectDir: String, oldVersion: String, newVersion: String) {
        self.configuration = configuration
        self.projectDir = projectDir
        self.oldVersion = oldVersion
        self.newVersion = newVersion
    }
}

extension GitDiffer {
    var diff: String {
        return shell(executablePath: gitExecutablePath, arguments: gitArguments, currentDirectoryPath: projectDir) ??
        ""
    }

    private var gitExecutablePath: String {
        if let path = configuration.gitExecutablePath {
            return path
        }
        guard let path = shell(executablePath: "/bin/bash", arguments: ["-c", "which git"], currentDirectoryPath: projectDir) else {
            return ""
        }

        return path.trimmingCharacters(in: .newlines)
    }

    private var gitArguments: [String] {
        return ["log", "--left-right", "--graph", "--cherry-pick", "--oneline", "--format=format:&&&%H&&& - @@@%s@@@###%ae###", "--date=short", "\(configuration.gitBranchPrefix)\(oldVersion)...\(configuration.gitBranchPrefix)\(newVersion)"]
    }
}
