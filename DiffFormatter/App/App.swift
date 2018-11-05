//
//  App.swift
//  DiffFormatter
//
//  Created by Dan Loman on 9/16/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct App {
    let buildNumber: String
    let name: String
    let version: String
}

extension App {
    init(bundle: Bundle = .main) {
        self.buildNumber = bundle.buildNumber
        self.name = bundle.appName
        self.version = bundle.version
    }
}

fileprivate extension Bundle {
    private enum InfoKey: String {
        case displayName = "CFBundleDisplayName"
        case version = "CFBundleShortVersionString"
        case buildNumber = "CFBundleVersion"
    }

    var appName: String {
        return info(for: .displayName)
    }

    var buildNumber: String {
        return info(for: .buildNumber)
    }

    var version: String {
        return info(for: .version)
    }

    private func info(for key: InfoKey) -> String {
        guard let dictionary = infoDictionary else {
            return "Unknown"
        }

        return dictionary[key.rawValue] as? String ?? "Unknown"
    }
}
