//
//  FileResolver.swift
//  DiffFormatter
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

    private let logError: (String) -> Void

    public init(fileManager: FileManager, pathComponent: String, logError: @escaping (String) -> Void) {
        self.fileManager = fileManager
        self.pathComponent = pathComponent
        self.logError = logError
    }

    public func resolve(path: String) -> FileType? {
        guard case let filePath = path + pathComponent, let data = fileManager.contents(atPath: filePath) else {
            return nil
        }

        do {
            return try decoder.decode(FileType.self, from: data)
        } catch {
            logError("Error parsing file of type \(FileType.self) at path: \(filePath). \n\nError details: \n\(error)")
            return nil
        }
    }
}
