//
//  Configurator.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct Configurator {

    private static let configDirPathComponent: String = "/.diff_formatter/config/"

    // Set defaults where possible
    private(set) var configuration: Configuration = .default

    private let fileManager: FileManager = .default

    init(processInfo: ProcessInfo) {
        guard case let home = fileManager.homeDirectoryForCurrentUser.path, !home.isEmpty else {
            return
        }

        // Load initial config from home directory if available
        if case let config = configuration(forBasePath: home), !config.isEmpty {
            configuration = configuration.modifiedConfig(withNonEmptyComponentsFrom: config)
        }

        if let value = processInfo.environment["DIFFFORMATTER_CONFIG"], !value.isEmpty {
            // Load config overrides from custom path if env var included
            if case let config = configuration(forBasePath: value), !config.isEmpty {
                configuration = configuration.modifiedConfig(withNonEmptyComponentsFrom: config)
            }
        } else if case let value = fileManager.currentDirectoryPath, !value.isEmpty {
            // Load config overrides from current directory if available
            if case let config = configuration(forBasePath: value), !config.isEmpty {
                configuration = configuration.modifiedConfig(withNonEmptyComponentsFrom: config)
            }
        }
    }

    private func configuration(forBasePath path: String) -> Configuration {
        guard !path.isEmpty else {
            return .empty
        }

        var users: [User] = []
        var sectionInfos: [SectionInfo] = []
        var footer: String?

        if let data = fileManager.contents(atPath: path + Configurator.pathComponent(for: .users)) {
            users = .from(data: data)
        }

        if let data = fileManager.contents(atPath: path + Configurator.pathComponent(for: .sectionInfos)) {
            sectionInfos = .from(data: data)
        }

        if let data = fileManager.contents(atPath: path + Configurator.pathComponent(for: .footer)) {
            footer = String(data: data, encoding: .utf8)
        }

        return .init(users: users, sectionInfos: sectionInfos, footer: footer)
    }

    private static func pathComponent(for configurationComponent: Configuration.Component) -> String {
        return configDirPathComponent + configurationComponent.rawValue
    }
}
