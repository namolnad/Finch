//
//  Utilities_Log.swift
//  DiffFormatter
//
//  Created by Dan Loman on 12/29/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

extension Utilities {
    struct Log {
        fileprivate static let instance: Log = .init()

        private let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            return formatter
        }()

        private var timeStamp: String {
            return formatter.string(from: Date())
        }

        private init() {}

        func info(_ message: String) {
            log(message: message)
        }

        private func log(message: String) {
            print("[\(timeStamp)]: \(message)")
        }
    }

    static let log: Log = .instance
}
