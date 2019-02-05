//
//  LogService.swift
//  DiffFormatterApp
//
//  Created by Dan Loman on 2/4/19.
//

import Foundation

protocol LogProviding {
    func log(options: GenerateCommand.Options, app: App, env: Environment) throws -> String
}

struct LogService: LogProviding {
    func log(options: GenerateCommand.Options, app: App, env: Environment) throws -> String {
        if let log = options.gitLog {
            return log
        }

        let git = Git(app: app, env: env)

        if !options.noFetch {
            app.print("Fetching origin", kind: .info)
            try git.fetch()
        }

        app.print("Generating log", kind: .info)

        return try git.log(oldVersion: options.versions.old, newVersion: options.versions.new)
    }
}
