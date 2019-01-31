//
//  Output.swift
//  DiffFormatterUtilities
//
//  Created by Dan Loman on 1/30/19.
//

import Foundation

public struct Output {
    public enum Kind {
        case `default`
        case error
        case info
    }

    private static let instance: Output = .init()

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    private var timeStamp: String {
        return formatter.string(from: Date())
    }

    private init() {}

    public static func print(_ value: String, kind: Kind, verbose: Bool = false) {
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

            Swift.print("[\(instance.timeStamp)]: \(value)")
        }
    }
}
