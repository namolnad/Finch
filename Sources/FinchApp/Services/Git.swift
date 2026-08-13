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
        try [
            "\(app.configuration.gitConfig.executablePath ?? executable(.git))",
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
        try git("fetch", "--quiet")
    }

    func versionsStringUsingTags() throws -> String {
        try git(
            "tag -l --sort=v:refname",
            "|",
            "\(executable(.tail)) -2",
            "|",
            "\(executable(.tr)) '\n' ' '"
        )
    }

    func versionsStringUsingBranches(semVerRegex: String) throws -> String {
        guard !app.configuration.gitConfig.branchPrefix.isEmpty else {
            return ""
        }

        return try git(
            "branch -r --list",
            "|",
            "\(executable(.grep)) -E '\(app.configuration.gitConfig.branchPrefix)\(semVerRegex)'",
            "|",
            "\(executable(.sort)) -V",
            "|",
            "\(executable(.tail)) -2",
            "|",
            "\(executable(.sed)) 's#\(app.configuration.gitConfig.branchPrefix)##'",
            "|",
            "\(executable(.tr)) '\n' ' '"
        )
    }

    private func git(_ args: String...) throws -> String {
        try Shell(env: app.environment).run(args: gitExecutableArgs() + args)
    }
}
