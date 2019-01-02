//
//  Configurator.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct Configurator {
    var configuration: Configuration {
        return getConfiguration()
    }

    // Paths for which the configurator should continue to modify the existing config with the next found config
    private let cascadingPaths: [String]

    private let configResolver: Utilities.FileResolver<Configuration>

    private let defaultConfig: Configuration

    // Paths for which the configurator should return the first valid configuration
    private let immediateReturnPaths: [String]

    init(processInfo: ProcessInfo, argScheme: ArgumentScheme, fileManager: FileManager = .default) {
        self.configResolver = .init(fileManager: fileManager, pathComponent: "/.diffformatter/config")
        self.defaultConfig = .default(currentDirectory: fileManager.currentDirectoryPath)

        self.immediateReturnPaths = [
            processInfo.environment["DIFFFORMATTER_CONFIG"]
        ].compactMap { $0 }

        var cascadingPaths = [
            fileManager.homeDirectoryForCurrentUser.path,
            fileManager.currentDirectoryPath
        ]

        // Append project dir if passed in as argument
        for case let .actionable(.projectDir, value) in argScheme.args {
            cascadingPaths.append(value)
            break
        }

        self.cascadingPaths = cascadingPaths
    }

    private func getConfiguration() -> Configuration {
        // Start with default configuration
        var configuration = defaultConfig

        if let config = immediateReturnPaths.firstMap(configResolver.resolve) {
            configuration.update(with: config)
            return configuration
        }

        for config in cascadingPaths.compactMap(configResolver.resolve) where !config.isBlank {
            configuration.update(with: config)
        }

        return configuration
    }
}
