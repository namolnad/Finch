//
//  Argument.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct Argument {
    static func commands(argument: String) -> CommandValue? {
        var arg = argument

        guard let range = arg.range(of: "--") else {
            // No command tag
            return nil
        }

        arg.removeSubrange(range)

        guard case let components = arg
            .components(separatedBy: "="),
            components.count == 2 else {
                // Malformed argument
                return nil
        }
        guard let command = Command(rawValue: components[0]) else {
            // Unrecognized argument
            return nil
        }
        return (command, components[1])
    }
}
