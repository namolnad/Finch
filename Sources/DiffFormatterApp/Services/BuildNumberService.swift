//
//  BuildNumberService.swift
//  DiffFormatterApp
//
//  Created by Dan Loman on 2/4/19.
//

import DiffFormatterUtilities
//import Foundation

protocol BuildNumberProviding {
    func buildNumber(options: GenerateCommand.Options, app: App, env: Environment) throws -> String?
}

struct BuildNumberService: BuildNumberProviding {
    func buildNumber(options: GenerateCommand.Options, app: App, env: Environment) throws -> String? {
        if let buildNumber = options.buildNumber {
            return buildNumber
        }

        guard let args = app.configuration.resolutionCommandsConfig.buildNumber, !args.isEmpty else {
                return nil
        }

        let environment: Environment = env.merging([
            "NEW_VERSION": "\(options.versions.new)",
            "PROJECT_DIR": "\(app.configuration.projectDir)"
        ]) { $1 }

        return try Shell(env: environment)
            .run(args: args)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
