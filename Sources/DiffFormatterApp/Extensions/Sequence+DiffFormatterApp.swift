//
//  Sequence+DiffFormatterApp.swift
//  DiffFormatterApp.swift
//
//  Created by Dan Loman on 1/2/19.
//  Copyright © 2019 DHL. All rights reserved.
//

import Foundation

extension Sequence {
    func firstMap<T>(_ transform: (Element) throws -> T?) rethrows -> T? {
        for element in self {
            if let transformed = try transform(element) {
                return transformed
            }
        }

        return nil
    }
}
