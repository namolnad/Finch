//
//  TestHelper.swift
//  FinchTests
//
//  Created by Dan Loman on 12/29/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation
import Yams

final class TestHelper {
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
