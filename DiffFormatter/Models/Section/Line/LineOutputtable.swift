//
//  LineOutputtable.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/23/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

protocol LineOutputtable {
    func output(components: LineComponents, configuration: Configuration, sectionInfo: Section.Info) -> String
}
