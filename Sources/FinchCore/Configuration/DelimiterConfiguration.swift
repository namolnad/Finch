//
//  DelimiterConfiguration.swift
//  FinchCore
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

/**
 * FormatConfiguration's sub-configuration for the project's tag delimiters.
 */
public struct DelimiterConfiguration: Equatable {
    /**
     * The delimiter pair surrounding a commit tag prior to
     * Finch processing.
     * > Defaults to left `[` and right `]`
     */
    public private(set) var input: DelimiterPair

    /**
     * The delimiter pair surrounding a commit tag in the final
     * Finch output.
     * > Defaults to left `|` and right `|`
     */
    public private(set) var output: DelimiterPair
}

/// :nodoc:
extension DelimiterConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case input
        case output
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        input = container.decode(forKey: .input, default: .blank)
        output = container.decode(forKey: .output, default: .blank)
    }
}

/// :nodoc:
extension DelimiterConfiguration: SubConfiguration {
    public static let `default`: DelimiterConfiguration = .init(
        input: .defaultInput,
        output: .defaultOutput
    )

    public static let blank: DelimiterConfiguration = .init(
        input: .blank,
        output: .blank
    )
}

/// :nodoc:
extension DelimiterConfiguration: Mergeable {
    public func merge(into other: inout DelimiterConfiguration) {
        if !input.isBlank {
            other.input = input
        }

        if !output.isBlank {
            other.output = output
        }
    }
}
