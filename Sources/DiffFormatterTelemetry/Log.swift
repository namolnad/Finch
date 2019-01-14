//
//  Log.swift
//  DiffFormatter
//
//  Created by Dan Loman on 12/29/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

public protocol Logger {
    func error(_ message: String)
    func info(_ message: String)
}

public let log: Logger = Log.instance

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

    public func error(_ message: String) {
        log(message: "🚨 \(message)")
    }

    public func info(_ message: String) {
        log(message: message)
    }

    private func log(message: String) {
        print("[\(timeStamp)]: \(message)")
    }
}
