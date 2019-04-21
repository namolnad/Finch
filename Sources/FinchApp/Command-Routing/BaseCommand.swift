//
//  BaseCommand.swift
//  FinchApp
//
//  Created by Dan Loman on 1/29/19.
//

import FinchUtilities
import SwiftCLI

///// :nodoc:
public typealias Environment = [String: String]

typealias AppGenerator = (_ configPath: String?, _ projectDir: String?, _ verbose: Bool) -> App

class BaseCommand: Command {
    var name: String { fatalError("Not implemented") }

    var shortDescription: String { fatalError("Not implemented") }

    var longDescription: String { return shortDescription }

    let appGenerator: AppGenerator

    init(appGenerator: @escaping AppGenerator) {
        self.appGenerator = appGenerator
    }

    func run(with app: App) throws {
        fatalError("Not implemented")
    }

    final func execute() throws {
        let app = appGenerator(configPath.value, projectDir.value, verbose.value)

        do {
            try run(with: app)
        } catch {
            app.print(error.localizedDescription)
        }
    }
}

extension BaseCommand {
    static var globalOptions: [Option] {
        return [
            verboseOption,
            configPathOption,
            projectDirOption
        ]
    }
}

private let verboseOption: Flag = .init("-v", "--verbose", description: Strings.App.Options.verbose)

private let configPathOption: Key<String> = .init("-c", "--config", description: Strings.App.Options.configPath)

private let projectDirOption: Key<String> = .init("--project-dir", description: Strings.App.Options.projectDir)

extension Command {
    var verbose: Flag {
        return verboseOption
    }

    var configPath: Key<String> {
        return configPathOption
    }

    var projectDir: Key<String> {
        return projectDirOption
    }
}
