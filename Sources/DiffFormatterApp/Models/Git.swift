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
    private func gitExecutableArgs() throws -> [String] {
        return [
            "\(try app.configuration.gitExecutablePath ?? executable(.git))",
            "--git-dir",
            "\(app.configuration.projectDir)/.git"
        ]
    }

    func log(oldVersion: Version, newVersion: Version) throws -> String {
        guard !isTest else {
            return ""
        }

        return try git(
            "log",
            "--left-right",
            "--graph",
            "--cherry-pick",
            "--oneline",
            "--format='format:&&&%H&&& - @@@%s@@@###%ae###'",
            "--date=short",
            "\(app.configuration.gitBranchPrefix)\(oldVersion)...\(app.configuration.gitBranchPrefix)\(newVersion)"
        )
    }

    @discardableResult
    func fetch() throws -> String {
        return try git("fetch")
    }

    func versionsStringUsingTags() throws -> String {
        return try git(
            "tag -l --sort=v:refname",
            "|",
            "\(try executable(.tail)) -2",
            "|",
            "\(try executable(.tr)) '\n' ' '"
        )
    }

    func versionsStringUsingBranches(semVerRegex: String) throws -> String {
        return try git(
            "branch -r --list",
            "|",
            "\(try executable(.grep)) -E '\(app.configuration.gitBranchPrefix)\(semVerRegex)'",
            "|",
            "\(try executable(.sort)) -V",
            "|",
            "\(try executable(.tail)) -2",
            "|",
            "\(try executable(.sed)) 's#\(app.configuration.gitBranchPrefix)##'",
            "|",
            "\(try executable(.tr)) '\n' ' '"
        )
    }

    private func git(_ args: String...) throws -> String {
        return try Shell(env: env).run(args: gitExecutableArgs() + args)
    }
}
