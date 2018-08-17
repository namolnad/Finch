//
//  DelimiterConfiguration.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct DelimiterConfiguration: Codable {
    let input: DelimiterPair
    let output: DelimiterPair
}

extension DelimiterConfiguration {
    static let `default`: DelimiterConfiguration = .init(input: .defaultInput, output: .defaultOutput)
}
