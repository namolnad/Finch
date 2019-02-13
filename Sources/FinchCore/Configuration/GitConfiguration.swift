//
//  GitConfiguration.swift
//  FinchCore
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

public struct GitConfiguration {
    public private(set) var branchPrefix: String?
    public private(set) var executablePath: String?
    public private(set) var repoBaseUrl: String
}

extension GitConfiguration: Decodable {
    enum CodingKeys: String, CodingKey {
        case branchPrefix
        case executablePath
        case repoBaseUrl
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.branchPrefix = container.optionalDecode(forKey: .branchPrefix)
        self.executablePath = container.optionalDecode(forKey: .executablePath)
        self.repoBaseUrl = container.decode(forKey: .repoBaseUrl, default: "")
    }
}

extension GitConfiguration: SubConfiguration {
    public static let blank: GitConfiguration = .init(
        branchPrefix: nil,
        executablePath: nil,
        repoBaseUrl: ""
    )

    public static var `default`: GitConfiguration { return .blank }
}

extension GitConfiguration: Mergeable {
    public func merge(into other: inout GitConfiguration) {
        if let branchPrefix = branchPrefix {
            other.branchPrefix = branchPrefix
        }

        if let executablePath = executablePath {
            other.executablePath = executablePath
        }

        if !repoBaseUrl.isEmpty {
            other.repoBaseUrl = repoBaseUrl
        }
    }
}
