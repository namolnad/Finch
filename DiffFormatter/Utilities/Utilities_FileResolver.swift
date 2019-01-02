//
//  Utilities_FileResolver.swift
//  DiffFormatter
//
//  Created by Dan Loman on 1/2/19.
//  Copyright © 2019 DHL. All rights reserved.
//

import Foundation

extension Utilities {
    final class FileResolver<FileType: Decodable> {
        private let fileManager: FileManager

        private let pathComponent: String

        private lazy var decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }()

        init(fileManager: FileManager, pathComponent: String) {
            self.fileManager = fileManager
            self.pathComponent = pathComponent
        }

        func resolve(path: String) -> FileType? {
            guard case let filePath = path + pathComponent, let data = fileManager.contents(atPath: filePath) else {
                return nil
            }

            do {
                return try decoder.decode(FileType.self, from: data)
            } catch {
                // swiftlint:disable line_length
                log.error("Error parsing file of type \(FileType.self) at path: \(filePath). \n\nError details: \n\(error)")
                // swiftlint:enable line_length
                return nil
            }
        }
    }
}
