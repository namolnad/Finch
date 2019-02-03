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
    let app: App
    let env: Environment
}

extension Git {
    private func executableArgs() throws -> [String] {
        return [
            "\(try app.configuration.gitExecutablePath ?? Executable.git.getPath())",
            "--git-dir",
            "\(app.configuration.projectDir)/.git"
        ]
    }

    func log(oldVersion: Version, newVersion: Version) throws -> String {
        guard !isTest else {
            return ""
        }

        return try execute(args: [
            "log",
            "--left-right",
            "--graph",
            "--cherry-pick",
            "--oneline",
            "--format='format:&&&%H&&& - @@@%s@@@###%ae###'",
            "--date=short",
            "\(app.configuration.gitBranchPrefix)\(oldVersion)...\(app.configuration.gitBranchPrefix)\(newVersion)"
        ])
    }

    @discardableResult
    func fetch() throws -> String {
        return try execute(args: ["fetch"])
    }

    func versionsStringUsingTags() throws -> String {
        return try execute(args: [
            "tag -l --sort=v:refname",
            "|",
            "\(try Executable.tail.getPath()) -2",
            "|",
            "\(try Executable.tr.getPath()) '\n' ' '"
        ])
    }

    func versionsStringUsingBranches(semVerRegex: String) throws -> String {
        return try execute(args: [
            "branch -r --list",
            "|",
            "\(try Executable.grep.getPath()) -E '\(app.configuration.gitBranchPrefix)\(semVerRegex)'",
            "|",
            "\(try Executable.sort.getPath()) -V",
            "|",
            "\(try Executable.tail.getPath()) -2",
            "|",
            "\(try Executable.sed.getPath()) 's#\(app.configuration.gitBranchPrefix)##'",
            "|",
            "\(try Executable.tr.getPath()) '\n' ' '"
        ])
    }

    private func execute(args: [String]) throws -> String {
        return try Shell(env: env).run(args: executableArgs() + args)
    }
}
