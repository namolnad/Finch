//
//  Argument.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

public enum Argument: Equatable {
    public enum ArgumentType: String {
        case buildNumber =          "--build-number"
        case gitDiff =              "--git-diff"
        case help =                 "--help"
        case helpAbbreviated =      "-h"
        case noFetch =              "--no-fetch"
        case noShowVersion =        "--no-show-version"
        case projectDir =           "--project-dir"
        case releaseManager =       "--release-manager"
        case version =              "--version"
        case versionAbbreviated =   "-v"
    }

    public typealias Value = String

    case flag(ArgumentType)
    case actionable(ArgumentType, Value)

    public init?(value: String) {
        let components = value.components(separatedBy: "=")

        guard let first = components.first, let argType = ArgumentType(rawValue: first) else {
            return nil
        }

        switch (components.count, components.last) {
        case (1, _):
            self = .flag(argType)
        case (2, let value?):
            self = .actionable(argType, value)
        default:
            return nil
        }
    }
}
