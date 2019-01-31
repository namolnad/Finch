//
//  Configurator.swift
//  DiffFormatterApp.swift
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import DiffFormatterCore
import DiffFormatterUtilities
import Foundation

struct Configurator {
    var configuration: Configuration {
        return getConfiguration()
    }

    // Paths for which the configurator should continue to modify the existing config with the next found config
    private let cascadingPaths: [String]

    private let cascadingResolver: FileResolver<Configuration>

    private let immediateResolver: FileResolver<Configuration>

    private let defaultConfig: Configuration

    // Paths for which the configurator should return the first valid configuration
    private let immediateReturnPaths: [String]

    init(processInfo: ProcessInfo, argScheme: ArgumentScheme, fileManager: FileManager = .default) {
        self.configResolver = .init(
        self.cascadingResolver = .init(
            fileManager: fileManager,
            pathComponent: "/.\(meta.name.lowercased())/config.json"
        )

        // The immediate resolver expects an exact path to be passed in through the environment variable
        self.immediateResolver = .init(fileManager: fileManager)

        let immediateReturnPaths = [
            processInfo.environment["DIFFFORMATTER_CONFIG"]
        ]

        self.immediateReturnPaths = immediateReturnPaths
            .compactMap { $0 }
            .filter { !$0.isEmpty }

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
        for case let .actionable(.projectDir, value) in argScheme.args {
            cascadingPaths.append(value)
            break
        }

        self.cascadingPaths = cascadingPaths.filter { !$0.isEmpty }
    }

    private func getConfiguration() -> Configuration {
        // Start with default configuration
        var configuration = defaultConfig

        do {
            if let config = try immediateReturnPaths.firstMap(immediateResolver.resolve) {
                configuration.update(with: config)
                return configuration
            }

            for config in try cascadingPaths.compactMap(cascadingResolver.resolve) where !config.isBlank {
                configuration.update(with: config)
            }
        } catch {
            Output.print("\(error)", kind: .error)
        }

        return configuration
    }
}
