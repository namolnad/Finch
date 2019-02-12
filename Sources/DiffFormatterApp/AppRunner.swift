//
//  AppRunner.swift
//  FinchApp
//
//  Created by Dan Loman on 1/29/19.
//

public class AppRunner {
    private let environment: Environment

    private let meta: App.Meta

    private let registry: CommandRegistry

    public init(environment: Environment, meta: App.Meta) {
        self.environment = environment
        self.meta = meta
        self.registry = .init(meta: meta)

        registry.register {
            GenerateCommand(meta: meta, parser: $0).bindingGlobalOptions(to: $1)
        }
    }

    public func run(arguments: [String]) throws {
        let args = Array(arguments.dropFirst())

        let (command, options, result) = try registry.parse(arguments: args)

        let config = Configurator(
            options: options,
            meta: meta,
            environment: environment
        ).configuration

        let app: App = .init(configuration: config, meta: meta, options: options)

        if let command = command {
            try registry.runCommand(
                named: command,
                with: result,
                app: app,
                env: environment
            )
        } else if options.shouldPrintVersion {
            app.print("\(app.meta.name) \(app.meta.version) (\(app.meta.buildNumber))")
        } else {
            registry.printUsage()
        }
    }
}
