//
//  FileResolver.swift
//  Finch
//
//  Created by Dan Loman on 1/2/19.
//  Copyright © 2019 DHL. All rights reserved.
//

import Foundation

public final class FileResolver<FileType: Decodable> {

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private let fileManager: FileManager

    private let pathComponent: String

    public init(fileManager: FileManager, pathComponent: String = "") {
        self.fileManager = fileManager
        self.pathComponent = pathComponent
    }

    public func resolve(path: String) throws -> FileType? {
        guard case let filePath = path + pathComponent, let data = fileManager.contents(atPath: filePath) else {
            return nil
        }

        return try decoder.decode(FileType.self, from: data)
    }
}
