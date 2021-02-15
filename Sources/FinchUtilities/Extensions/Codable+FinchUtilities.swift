//
//  Codable+FinchUtilities.swift
//  FinchUtilities
//
//  Created by Dan Loman on 11/23/18.
//  Copyright © 2018 DHL. All rights reserved.
//

extension KeyedDecodingContainer {
    public func decode<T: Decodable>(forKey key: Key) throws -> T {
        try decode(T.self, forKey: key)
    }

    public func optionalDecode<T: Decodable>(forKey key: Key) -> T? {
        try? decode(forKey: key)
    }

    public func decode<T: Decodable>(forKey key: Key, default: T) -> T {
        optionalDecode(forKey: key) ?? `default`
    }
}
