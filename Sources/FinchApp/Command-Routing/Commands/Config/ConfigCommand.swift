//
//  ConfigCommand.swift
//  FinchApp
//
//  Created by Dan Loman on 2/14/19.
//

import FinchCore
import FinchUtilities
import SwiftCLI
import Yams

/// Command to run configuration-centric operations.
final class ConfigGroup: CommandGroup {
    let children: [Routable]

    var name: String { Strings.Config.commandName }

    let shortDescription: String = Strings.Config.commandOverview

    init(children: [Routable]) {
        self.children = children
    }
}

final class ConfigExampleCommand: BaseCommand {
    override var name: String { Strings.Config.Example.commandName }

    override var shortDescription: String { Strings.Config.Example.commandOverview }

    override func run(with app: App) throws {
        let exampleConfig: Configuration = .example(projectDir: app.configuration.projectDir)

        app.print(try YAMLEncoder().encode(exampleConfig))
    }
}
