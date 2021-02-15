//
//  Output.swift
//  FinchUtilities
//
//  Created by Dan Loman on 1/30/19.
//

import Foundation

public protocol OutputType {
    func print(_ value: String, kind: Output.Kind, verbose: Bool)
}

public struct Output: OutputType {
    public enum Kind {
        case `default`
        case error
        case info
    }

    public static let instance: Output = .init()

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    private var timeStamp: String {
        formatter.string(from: Date())
    }

    private init() {}

    public func print(_ value: String, kind: Kind, verbose: Bool = false) {
        switch kind {
        case .default:
            Swift.print(value)
        case .error:
            fputs("🚨 \(value)\n", stderr)

            exit(EXIT_FAILURE)
        case .info:
            guard verbose else {
                return
            }

            Swift.print("[\(timeStamp)]: \(value)")
        }
    }
}
