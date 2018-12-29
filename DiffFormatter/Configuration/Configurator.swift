//
//  Configurator.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct Configurator {
    private static let configFilePathComponent: String = "/.diff_formatter"

    private(set) var configuration: Configuration

    private let fileManager: FileManager

    init(processInfo: ProcessInfo, argScheme: ArgumentScheme, fileManager: FileManager = .default) {
        self.fileManager = fileManager

        // Start with default configuration
        self.configuration = .default(currentDirectory: fileManager.currentDirectoryPath)

        // Return early if env var config is passed in
        if let value = processInfo.environment["DIFF_FORMATTER_CONFIG"], !value.isEmpty {
            if let config = configuration(forPath: value), !config.isBlank {
                configuration.update(with: config)
                return
            }
        }

        guard case let home = fileManager.homeDirectoryForCurrentUser.path, !home.isEmpty else {
            return
        }

        // Load initial config from home directory if available
        if let config = configuration(forPath: home), !config.isBlank {
            configuration.update(with: config)
        }

        // Load config overrides from current directory if available
        if case let value = fileManager.currentDirectoryPath, !value.isEmpty {
            if let config = configuration(forPath: value), !config.isBlank {
                configuration.update(with: config)
            }
        }

        // Load config from project dir if passed in as argument
        for case let .actionable(.projectDir, value) in argScheme.args {
            if let config = configuration(forPath: value), !config.isBlank {
                configuration.update(with: config)
            }
            break
        }
    }

    private func configuration(forPath path: String) -> Configuration? {
        let filePath = path + type(of: self).configFilePathComponent

        guard let data = fileManager.contents(atPath: filePath) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(Configuration.self, from: data)
        } catch {
            log.error("Error parsing configuration at path: \(filePath). \n\nError details: \n\(error)")
            return nil
        }
    }
}
