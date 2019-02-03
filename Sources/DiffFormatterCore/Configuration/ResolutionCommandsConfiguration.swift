//
//  ResolutionCommandsConfiguration.swift
//  DiffFormatterCore
//
//  Created by Dan Loman on 2/3/19.
//

import Foundation

public struct ResolutionCommandsConfiguration: Decodable {
    public let buildNumber: [String]?
    public let versions: [String]?
}

extension ResolutionCommandsConfiguration {
    public static let blank: ResolutionCommandsConfiguration = .init(buildNumber: nil, versions: nil)
}

extension ResolutionCommandsConfiguration {
    var isBlank: Bool {
        return [buildNumber, versions]
            .reduce(true) { $0 && $1?.isEmpty == true }
    }
}
