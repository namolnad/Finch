//
//  CompareCommandTests.swift
//  FinchAppTests
//
//  Created by Dan Loman on 1/31/19.
//

@testable import FinchApp
import SnapshotTesting
import XCTest

final class CompareCommandTests: XCTestCase {
    func testCommandName() {
        let command = CompareCommand(meta: .mock, parser: .init(usage: "blah", overview: ""))

        XCTAssertEqual(command.name, "compare")
    }
}
