//
//  TestHelper.swift
//  DiffFormatterTests
//
//  Created by Dan Loman on 12/29/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

final class TestHelper {
    static func model<T: Decodable>(for path: String) -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try! decoder.decode(T.self, from: data(for: path))
    }

    static func data(for path: String) -> Data {
        let resource = Bundle(for: TestHelper.self)
            .path(forResource: path, ofType: "json")!

        return try! Data(contentsOf: URL(fileURLWithPath: resource))
    }
}
