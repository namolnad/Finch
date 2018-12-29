//
//  Utilities_Log.swift
//  DiffFormatter
//
//  Created by Dan Loman on 12/29/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

protocol Logger {
    func error(_ message: String)
    func info(_ message: String)
}

let log: Logger = Utilities.log

extension Utilities {
    struct Log: Logger {
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

        func error(_ message: String) {
            log(message: "🚨 \(message)")
        }

        func info(_ message: String) {
            log(message: message)
        }

        private func log(message: String) {
            print("[\(timeStamp)]: \(message)")
        }
    }

    static let log: Logger = Log.instance
}
