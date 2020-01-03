//
//  Git.swift
//  FinchApp.swift
//
//  Created by Dan Loman on 12/29/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import FinchCore
import FinchUtilities
import Version

/// :nodoc:
struct Git {
    let app: App
}

/// :nodoc:
extension Git {
    private func gitExecutableArgs() throws -> [String] {
        return [
            "\(try app.configuration.gitConfig.executablePath ?? executable(.git))",
            "--git-dir",
            "\(app.configuration.projectDir)/.git"
        ]
    }

    func log(oldVersion: Version, newVersion: Version) throws -> String {
        let prefix = app.configuration.gitConfig.branchPrefix

        return try git(
            "log",
            "--left-right",
            "--cherry-pick",
            "--oneline",
            "--format='format:&&&%H&&& - @@@%s@@@###%ae###'",
            "--date=short",
            "\(prefix)\(oldVersion)...\(prefix)\(newVersion)"
        )
    }

    @discardableResult
    func fetch() throws -> String {
        return try git("fetch", "--quiet")
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
        guard !app.configuration.gitConfig.branchPrefix.isEmpty else {
            return ""
        }

        return try git(
            "branch -r --list",
            "|",
            "\(try executable(.grep)) -E '\(app.configuration.gitConfig.branchPrefix)\(semVerRegex)'",
            "|",
            "\(try executable(.sort)) -V",
            "|",
            "\(try executable(.tail)) -2",
            "|",
            "\(try executable(.sed)) 's#\(app.configuration.gitConfig.branchPrefix)##'",
            "|",
            "\(try executable(.tr)) '\n' ' '"
        )
    }

    private func git(_ args: String...) throws -> String {
        return try Shell(env: app.environment).run(args: gitExecutableArgs() + args)
    }
}
