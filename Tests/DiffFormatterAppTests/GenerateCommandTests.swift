//
//  GenerateCommandTests.swift
//  DiffFormatterAppTests
//
//  Created by Dan Loman on 1/31/19.
//

@testable import DiffFormatterApp
import SnapshotTesting
import XCTest

final class GenerateCommandTests: XCTestCase {
    func testCommandName() {
        let command = GenerateCommand(meta: .mock, parser: .init(usage: "blah", overview: ""))

        XCTAssertEqual(command.name, "generate")
    }
}
