//
//  VersionsResolver.swift
//  FinchApp
//
//  Created by Dan Loman on 2/3/19.
//

import Foundation

protocol VersionResolving {
    func versions(from versionString: String) throws -> (old: Version, new: Version)
}

struct VersionsResolver: VersionResolving {
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

    func versions(from versionString: String) throws -> (old: Version, new: Version) {
        guard case let versionStrings = versionString.split(separator: " "),
            versionStrings.count == 2,
            let firstVersionString = versionStrings.first,
            let secondVersionString = versionStrings.last else {
            throw Error.unableToResolveVersion
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
