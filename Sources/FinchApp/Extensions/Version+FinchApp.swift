//
//  Version+FinchApp.swift
//  FinchApp
//
//  Created by Dan Loman on 1/29/19.
//

/// :nodoc:
extension Version: ArgumentKind {
    public static var completion: ShellCompletion {
        return .none
    }

    public init(argument: String) throws {
        guard let version = Version(string: argument) else {
            throw ArgumentConversionError.typeMismatch(value: argument, expectedType: Version.self)
        }

        self = version
    }
}
