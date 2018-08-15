//
//  Configurator.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct Configurator {

    let configuration: Configuration

    let fileManager: FileManager = .default

    init(processInfo: ProcessInfo) {
        // Set defaults where possible
        var users: [User] = []
        var sectionInfos: [SectionInfo] = SectionInfo.defaultSectionInfos

        let home = fileManager.homeDirectoryForCurrentUser.path

        if !home.isEmpty {
            // Load initial config from home directory if available
            if let data = fileManager.contents(atPath: home + Configurator.pathComponent(for: .users)) {
                users = .from(data: data)
            }
            if let data = fileManager.contents(atPath: home + Configurator.pathComponent(for: .sectionInfos)) {
                sectionInfos = .from(data: data)
            }
        }

        if let value = processInfo.environment["DIFFFORMATTER_CONFIG"], !value.isEmpty, !home.isEmpty {
            // Load config overrides from custom path if env var included
            if let data = fileManager.contents(atPath: home + value + Configurator.pathComponent(for: .users)) {
                users = .from(data: data)
            }
            if let data = fileManager.contents(atPath: home + value + Configurator.pathComponent(for: .sectionInfos)) {
                sectionInfos = .from(data: data)
            }
        } else if case let value = fileManager.currentDirectoryPath, !value.isEmpty {
            // Load config overrides from current directory if available
            if let data = fileManager.contents(atPath: value + Configurator.pathComponent(for: .users)) {
                users = .from(data: data)
            }
            if let data = fileManager.contents(atPath: value + Configurator.pathComponent(for: .sectionInfos)) {
                sectionInfos = .from(data: data)
            }
        }

        self.configuration = .init(users: users, sectionInfos: sectionInfos)
    }

    private static func pathComponent(for configurationComponent: Configuration.Component) -> String {
        return "/.diffformatter/config/" + configurationComponent.rawValue
    }
}
