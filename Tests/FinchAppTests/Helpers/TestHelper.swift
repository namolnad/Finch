//
//  TestHelper.swift
//  FinchTests
//
//  Created by Dan Loman on 12/29/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation
import Yams
#if !swift(>=5.0)
import SnapshotTesting
#endif
import XCTest

#if swift(>=5.0)
typealias TestCase = XCTestCase
#else
typealias TestCase = SnapshotTestCase
#endif

final class TestHelper {
    static var isMacOS: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }

    private let decoder: YAMLDecoder = .init()

    private static let instance: TestHelper = .init()

    private init() {}

    static func model<T: Decodable>(for path: String) -> T {
        let encodedYaml = String(data: data(for: path), encoding: .utf8)!
        return try! instance.decoder.decode(from: encodedYaml)
    }

    static func data(for path: String) -> Data {
        let resource = Resource(name: path, type: "yml")

        return try! Data(contentsOf: URL(fileURLWithPath: resource.path))
    }
}
