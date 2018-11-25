//
//  GitConfiguration.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct GitConfiguration {
    enum CodingKeys: String, CodingKey {
        case branchPrefix
        case executablePath
        case repoBaseUrl
    }

    let branchPrefix: String?
    let executablePath: String?
    let repoBaseUrl: String
}

extension GitConfiguration: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.branchPrefix = container.optionalDecode(forKey: .branchPrefix)
        self.executablePath = container.optionalDecode(forKey: .executablePath)
        self.repoBaseUrl = container.decode(forKey: .repoBaseUrl, default: "")
    }
}

extension GitConfiguration {
    static let blank: GitConfiguration = .init(branchPrefix: nil, executablePath: nil, repoBaseUrl: "")
    static let `default`: GitConfiguration = .init(branchPrefix: "", executablePath: nil, repoBaseUrl: "")
}

extension GitConfiguration {
    var isBlank: Bool {
        return (branchPrefix?.isEmpty == true) &&
            (executablePath?.isEmpty == true)
    }
}
