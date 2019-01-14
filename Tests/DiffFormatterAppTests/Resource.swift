//
//  Resource.swift
//  DiffFormatter
//
//  Created by Dan Loman on 1/14/19.
//  Copyright © 2019 DHL. All rights reserved.
//

import Foundation

struct Resource {

    private let name: String

    private let type: String

    init(name: String, type: String) {
        self.name = name
        self.type = type
    }

    var path: String {
        guard let path = Bundle(for: TestHelper.self).path(forResource: name, ofType: type.isEmpty ? nil : type) else {
            let url = URL(fileURLWithPath: #file)
                .deletingLastPathComponent()
                .appendingPathComponent("Resources")
                .appendingPathComponent(name)

            if !type.isEmpty {
                return url.appendingPathExtension(type).path
            }

            return url.path
        }

        return path
    }
}
