//
//  BaseCommand.swift
//  FinchApp
//
//  Created by Dan Loman on 1/29/19.
//

import FinchUtilities
import SwiftCLI

/// :nodoc:
public typealias Environment = [String: String]

/// Function type which generates the App for the command at runtime.
typealias AppGenerator = (_ configPath: String?, _ projectDir: String?, _ verbose: Bool) -> App

/// Abstract base command class. All commands should subclass BaseCommand.
class BaseCommand: Command {
    /// **[Required]** The name of the command. Must be implemented by subclass.
    var name: String { fatalError("Not implemented") }

    /// **[Required]** A short description of the command. Must be implemented by subclass.
    var shortDescription: String { fatalError("Not implemented") }

    /// **[Optional]** A longer description displayed when command-specific help is presented.
    var longDescription: String { shortDescription }

    /// :nodoc:
    let appGenerator: AppGenerator

    /// :nodoc:
    init(appGenerator: @escaping AppGenerator) {
        self.appGenerator = appGenerator
    }

    /// **[Required]** The function containing execution of the command. Must be implemented by subclass.
    func run(with app: App) throws {
        fatalError("Not implemented")
    }

    /// Should NOT be implemented by a subclass. Defers execution to `BaseCommand.run(with:)`
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
    /// Global options for all commands: --verbose, --config, --project-dir
    static var globalOptions: [Option] {
        [
            verboseOption,
            configPathOption,
            projectDirOption
        ]
    }
}

private let verboseOption: Flag = .init("-v", "--verbose", description: Strings.App.Options.verbose)

private let configPathOption: Key<String> = .init("-c", "--config", description: Strings.App.Options.configPath)

private let projectDirOption: Key<String> = .init("--project-dir", description: Strings.App.Options.projectDir)

/// :nodoc:
extension Command {
    var verbose: Flag {
        verboseOption
    }

    var configPath: Key<String> {
        configPathOption
    }

    var projectDir: Key<String> {
        projectDirOption
    }
}
