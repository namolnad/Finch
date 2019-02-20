//
//  VersionsResolver.swift
//  FinchApp
//
//  Created by Dan Loman on 2/3/19.
//

import Foundation

/// Protocol describing a version-resolving type.
protocol VersionsResolving {
    /// Resolves an old and new version from a space separated version string.
    func versions(from versionString: String) throws -> (old: Version, new: Version)
}

/// A concrete type conforming to VersionResolving protocol.
struct VersionsResolver: VersionsResolving {
    /// :nodoc:
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

    /// See `VersionsResolving.versions(from:)` for definition.
    func versions(from versionString: String) throws -> (old: Version, new: Version) {
        guard case let versionStrings = versionString.split(separator: " "),
            versionStrings.count == 2,
            let firstVersionString = versionStrings.first,
            let secondVersionString = versionStrings.last else {
            throw Error.unableToResolveVersion
        }
        let firstVersion = try Version(argument: String(firstVersionString))
        let secondVersion = try Version(argument: String(secondVersionString))

        guard firstVersion < secondVersion else {
            return (secondVersion, firstVersion)
        }

        return (firstVersion, secondVersion)
    }
}
