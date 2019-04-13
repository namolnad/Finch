//
//  App.swift
//  FinchApp
//
//  Created by Dan Loman on 1/13/19.
//  Copyright © 2019 DHL. All rights reserved.
//

import Version
import struct FinchCore.Configuration
import FinchUtilities

/// :nodoc:
public typealias Version = Version.Version

/// A structure to represent this app and its components.
public struct App {

    /// The meta information of the app.
    public struct Meta {
        /// The app's current build number.
        let buildNumber: Int

        /// The app's name.
        let name: String

        /// The app's current version.
        let version: Version

        /// :nodoc:
        public init(buildNumber: Int, name: String, version: Version) {
            self.buildNumber = buildNumber
            self.name = name
            self.version = version
        }
    }

    /// App options received from the commandline.
    struct Options {
        /// Path to config
        var configPath: String?

        /// The project directory if it is not the current working directory.
        var projectDir: String?

        /// Print the app version information and exit.
        var shouldPrintVersion: Bool

        /// Execute with verbose output.
        var verbose: Bool
    }

    /// The app's derived configuration.
    let configuration: Configuration

    /// The app's meta-information.
    let meta: Meta

    /// The app's options derived from the commandline.
    let options: Options

    /// The current print destination for the app,
    private let output: OutputType

    /// :nodoc:
    init(configuration: Configuration, meta: Meta, options: Options, output: OutputType = Output.instance) {
        self.configuration = configuration
        self.meta = meta
        self.options = options
        self.output = output
    }

    /// Prints to the app's output.
    func print(_ value: String, kind: Output.Kind = .default) {
        output.print(value, kind: kind, verbose: options.verbose)
    }
}

/// :nodoc:
extension App.Options {
    static let blank: App.Options = .init(
        configPath: nil,
        projectDir: nil,
        shouldPrintVersion: false,
        verbose: false
    )
}
