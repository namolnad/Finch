//
//  Configurator.swift
//  FinchApp.swift
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import FinchCore
import FinchUtilities
import Foundation

struct Configurator {
    var configuration: Configuration {
        return getConfiguration()
    }

    // Paths for which the configurator should continue to modify the existing config with the next found config
    private let cascadingPaths: [String]

    private let cascadingResolver: FileResolver<Configuration>

    private let defaultConfig: Configuration

    // Paths for which the configurator should return the first valid configuration
    private let immediateResolver: FileResolver<Configuration>

    private let immediateReturnPaths: [String]

    private let output: OutputType

    init(
        options: App.Options,
        meta: App.Meta,
        environment: Environment,
        fileManager: FileManager = .default,
        output: OutputType = Output.instance) {
        self.cascadingResolver = .init(
            fileManager: fileManager,
            pathComponent: "/.\(meta.name.lowercased())/config.json"
        )

        // The immediate resolver expects an exact path to be passed in through the environment variable
        self.immediateResolver = .init(fileManager: fileManager)

        let immediateReturnPaths = [
            environment["\(meta.name.uppercased())_CONFIG"]
        ]

        self.immediateReturnPaths = immediateReturnPaths
            .compactMap { $0 }
            .filter { !$0.isEmpty }

        self.defaultConfig = .default(projectDir: options.projectDir ?? fileManager.currentDirectoryPath)

        self.output = output

        let homeDirectoryPath: String
        if #available(OSX 10.12, *) {
            homeDirectoryPath = fileManager.homeDirectoryForCurrentUser.path
        } else {
            homeDirectoryPath = NSHomeDirectory()
        }

        var cascadingPaths = [
            homeDirectoryPath,
            fileManager.currentDirectoryPath
        ]

        // Append project dir if passed in as argument
        if let value = options.projectDir {
            cascadingPaths.append(value)
        }

        self.cascadingPaths = cascadingPaths.filter { !$0.isEmpty }
    }

    private func getConfiguration() -> Configuration {
        // Start with default configuration
        var configuration = defaultConfig

        do {
            if let config = try immediateReturnPaths.firstMap(immediateResolver.resolve) {
                config.merge(into: &configuration)
                return configuration
            }

            for config in try cascadingPaths.compactMap(cascadingResolver.resolve) {
                config.merge(into: &configuration)
            }
        } catch {
            output.print("\(error)", kind: .error, verbose: false)
        }

        return configuration
    }
}
