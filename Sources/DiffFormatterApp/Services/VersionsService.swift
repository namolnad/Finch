//
//  VersionsService.swift
//  DiffFormatterApp
//
//  Created by Dan Loman on 2/3/19.
//

import Foundation

protocol VersionResolving {
    func versions(app: App, env: Environment) throws -> (old: Version, new: Version)
}

struct VersionsService: VersionResolving {
    enum Error: LocalizedError {
        case unableToResolveVersion

        var failureReason: String? {
            switch self {
            case .unableToResolveVersion:
                return NSLocalizedString(
                    "Unable to automatically resolve versions. Pass versions in directly through --versions option",
                    comment: "Error message indicating inability to auto-resolve versions"
                )
            }
        }
    }

    private let provider: VersionStringProviding

    init(provider: VersionStringProviding = VersionStringService()) {
        self.provider = provider
    }

    func versions(app: App, env: Environment) throws -> (old: Version, new: Version) {
        guard let versions = try versions(from: try provider.versionsString(app: app, env: env)) else {
            throw Error.unableToResolveVersion
        }

        return versions
    }

    private func versions(from versionString: String) throws -> (old: Version, new: Version)? {
        guard case let versionStrings = versionString.split(separator: " "),
            versionStrings.count == 2,
            let firstVersionString = versionStrings.first,
            let secondVersionString = versionStrings.last else {
                return nil
        }
        let firstVersion = try Version(argument: String(firstVersionString))
        let secondVersion = try Version(argument: String(secondVersionString))

        if firstVersion < secondVersion {
            return (firstVersion, secondVersion)
        } else {
            return (secondVersion, firstVersion)
        }
    }
}
