//
//  VersionsResolver.swift
//  FinchApp
//
//  Created by Dan Loman on 2/3/19.
//

import Foundation
import Version

/// Protocol describing a version-resolving type.
protocol VersionsResolving {
    /// Resolves an old and new version from a space separated version string.
    func versions(from versionString: String) throws -> (old: Version, new: Version)
}

/// A concrete type conforming to `VersionsResolving` protocol.
struct VersionsResolver: VersionsResolving {
    /// :nodoc:
    enum Error: LocalizedError {
        case unableToResolveVersion

        var failureReason: String? {
            switch self {
            case .unableToResolveVersion:
                return Strings.Compare.Error.unableToResolve
            }
        }
    }

    /// See `VersionsResolving.versions(from:)` for definition.
    func versions(from versionString: String) throws -> (old: Version, new: Version) {
        guard
            case let versionStrings = versionString.split(separator: " "),
            versionStrings.count == 2,
            let firstVersionString = versionStrings.first,
            let secondVersionString = versionStrings.last,
            let firstVersion = Version(String(firstVersionString)),
            let secondVersion = Version(String(secondVersionString))
        else { throw Error.unableToResolveVersion }

        guard firstVersion < secondVersion else {
            return (secondVersion, firstVersion)
        }

        return (firstVersion, secondVersion)
    }
}
