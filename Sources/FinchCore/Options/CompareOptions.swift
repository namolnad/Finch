//
//  CompareOptions.swift
//  FinchCore
//
//  Created by Dan Loman on 2/12/19.
//

import struct Utility.Version

public struct CompareOptions {
    public var versions: (old: Version, new: Version)
    public var buildNumber: String?
    public var gitLog: String?
    public var normalizeTags: Bool
    public var noFetch: Bool
    public var noShowVersion: Bool
    public var releaseManager: String?
    public var toPasteBoard: Bool
}

extension CompareOptions {
    public static let blank: CompareOptions = .init(
        versions: (.init(0, 0, 0), .init(0, 0, 0)),
        buildNumber: nil,
        gitLog: nil,
        normalizeTags: false,
        noFetch: false,
        noShowVersion: false,
        releaseManager: nil,
        toPasteBoard: false
    )
}
