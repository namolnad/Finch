//
//  App.swift
//  DiffFormatterApp
//
//  Created by Dan Loman on 1/13/19.
//  Copyright © 2019 DHL. All rights reserved.
//

import struct Utility.Version
import struct DiffFormatterCore.Configuration
import struct DiffFormatterUtilities.Output

typealias Version = Utility.Version

public struct App {
    public struct Meta {
        public typealias Version = Utility.Version

        let buildNumber: Int
        let name: String
        let version: Version

        public init(buildNumber: Int, name: String, version: Version) {
            self.buildNumber = buildNumber
            self.name = name
            self.version = version
        }
    }
    public struct Options {
        var projectDir: String?
        var shouldPrintVersion: Bool
        var verbose: Bool
    }

    public let configuration: Configuration
    public let meta: Meta
    public let options: Options

    func print(_ value: String, kind: Output.Kind = .default) {
        Output.print(value, kind: kind, verbose: options.verbose)
    }
}

extension App.Options {
    static let blank: App.Options = .init(
        projectDir: nil,
        shouldPrintVersion: false,
        verbose: false
    )
}
