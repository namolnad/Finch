//
//  DelimiterConfiguration.swift
//  DiffFormatterCore
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

public struct DelimiterConfiguration: Decodable, Equatable {
    enum CodingKeys: String, CodingKey {
        case input
        case output
    }
    public let input: DelimiterPair
    public let output: DelimiterPair

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        input = (try? container.decode(DelimiterPair.self, forKey: .input)) ?? .blank
        output = (try? container.decode(DelimiterPair.self, forKey: .output)) ?? .blank
    }

    public init(input: DelimiterPair, output: DelimiterPair) {
        self.input = input
        self.output = output
    }
}

extension DelimiterConfiguration {
    public static let `default`: DelimiterConfiguration = .init(input: .defaultInput, output: .defaultOutput)

    public static let blank: DelimiterConfiguration = .init(input: .blank, output: .blank)
}

extension DelimiterConfiguration {
    var isBlank: Bool {
        return input.isBlank && output.isBlank
    }
}
