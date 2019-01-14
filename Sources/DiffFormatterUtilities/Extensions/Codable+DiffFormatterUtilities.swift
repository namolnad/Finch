//
//  Codable+DiffFormatterUtilities.swift
//  DiffFormatterUtilities
//
//  Created by Dan Loman on 11/23/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
    public func decode<T: Decodable>(forKey key: Key) throws -> T {
        return try decode(T.self, forKey: key)
    }

    public func optionalDecode<T: Decodable>(forKey key: Key) -> T? {
        return try? decode(forKey: key)
    }

    public func decode<T: Decodable>(forKey key: Key, default: T) -> T {
        return optionalDecode(forKey: key) ?? `default`
    }
}
