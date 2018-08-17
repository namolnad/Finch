//
//  FileManagerMock.swift
//  DiffFormatterTests
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

final class FileManagerMock: FileManager {

    override var currentDirectoryPath: String {
        return "current"
    }

    override var homeDirectoryForCurrentUser: URL {
        return URL(string: "home")!
    }

    private let customConfigPath: String?

    init(customConfigPath: String? = nil) {
        self.customConfigPath = customConfigPath
    }

    override func contents(atPath path: String) -> Data? {
        switch path.components(separatedBy: "/").first! {
        case currentDirectoryPath:
            return nil
        case homeDirectoryForCurrentUser.path:
            return data(for: "default_config")
        case customConfigPath:
            fatalError()
        default:
            fatalError()
        }
    }

    private func data(for path: String) -> Data {
        let resource = Bundle(for: type(of:self)).path(forResource: path, ofType: "json")!

        return try! Data(contentsOf: URL(fileURLWithPath: resource))
    }
}
