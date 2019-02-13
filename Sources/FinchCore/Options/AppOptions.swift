//
//  AppOptions.swift
//  FinchCore
//
//  Created by Dan Loman on 2/12/19.
//

public struct AppOptions {
    public var projectDir: String?
    public var shouldPrintVersion: Bool
    public var verbose: Bool
}

extension AppOptions {
    public static let blank: AppOptions = .init(
        projectDir: nil,
        shouldPrintVersion: false,
        verbose: false
    )
}
