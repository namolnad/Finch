//
//  App.swift
//  FinchApp
//
//  Created by Dan Loman on 1/13/19.
//  Copyright © 2019 DHL. All rights reserved.
//

import struct Utility.Version
import FinchCore
import FinchUtilities

typealias Version = Utility.Version

public struct App {
    struct Options {
        public internal(set) var projectDir: String?
        public internal(set) var shouldPrintVersion: Bool
        public internal(set) var verbose: Bool
    }

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

    let configuration: Configuration
    let meta: Meta
    let options: Options
    private let output: OutputType

    init(configuration: Configuration, meta: Meta, options: Options, output: OutputType = Output.instance) {
        self.configuration = configuration
        self.meta = meta
        self.options = options
        self.output = output
    }

    func print(_ value: String, kind: Output.Kind = .default) {
        output.print(value, kind: kind, verbose: options.verbose)
    }
}

extension App.Options {
    static let blank: App.Options = .init(
        projectDir: nil,
        shouldPrintVersion: false,
        verbose: false
    )
}
