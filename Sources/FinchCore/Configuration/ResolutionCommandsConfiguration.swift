//
//  ResolutionCommandsConfiguration.swift
//  FinchCore
//
//  Created by Dan Loman on 2/3/19.
//

public struct ResolutionCommandsConfiguration {
    public private(set) var buildNumber: [String]?
    public private(set) var versions: [String]?
}

extension ResolutionCommandsConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case buildNumber = "build_number"
        case versions
    }
}

extension ResolutionCommandsConfiguration: SubConfiguration {
    public static let blank: ResolutionCommandsConfiguration = .init(
        buildNumber: nil,
        versions: nil
    )

    public static var `default`: ResolutionCommandsConfiguration { return .blank }
}

extension ResolutionCommandsConfiguration: Mergeable {
    public func merge(into other: inout ResolutionCommandsConfiguration) {
        if let buildNumber = buildNumber, !buildNumber.isEmpty {
            other.buildNumber = buildNumber
        }

        if let versions = versions, !versions.isEmpty {
            other.versions = versions
        }
    }
}
