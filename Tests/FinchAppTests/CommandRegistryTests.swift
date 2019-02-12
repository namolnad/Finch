//
//  CommandRegistryTests.swift
//  FinchAppTests
//
//  Created by Dan Loman on 1/31/19.
//

@testable import FinchApp
import SnapshotTesting
import XCTest

final class CommandRegistryTests: XCTestCase {
    func testParsingVersion() {
        let registry = CommandRegistry(meta: .mock)

        let parsingResult = try! registry.parse(arguments: ["-V"])

        assertSnapshot(matching: (parsingResult.0, parsingResult.1), as: .dump)
    }

    func testParsingGenerate() {
        let args: [String] = [
            "gen",
            "--versions",
            "6.12.1",
            "6.13.0",
            "--git-log=\(defaultInputMock)"
        ]

        let registry = CommandRegistry(meta: .mock)

        registry.register {
            CompareCommand(meta: .mock, parser: $0).bindingGlobalOptions(to: $1)
        }

        let parsingResult = try! registry.parse(arguments: args)

        assertSnapshot(matching: (parsingResult.0, parsingResult.1), as: .dump)
    }

    func testParsingGenerateManyOptions() {
        let args: [String] = [
            "gen",
            "--versions",
            "6.12.1",
            "6.13.0",
            "--git-log=\(defaultInputMock)",
            "--no-fetch",
            "--no-show-version",
            "--verbose",
            "--to-pasteboard",
            "--release-manager",
            "frank",
            "--build-number=15"
        ]

        let registry = CommandRegistry(meta: .mock)

        registry.register {
            CompareCommand(meta: .mock, parser: $0).bindingGlobalOptions(to: $1)
        }

        let parsingResult = try! registry.parse(arguments: args)

        assertSnapshot(matching: (parsingResult.0, parsingResult.1), as: .dump)
    }
}
