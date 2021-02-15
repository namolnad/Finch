//
//  CompareCommandTests.swift
//  FinchAppTests
//
//  Created by Dan Loman on 1/31/19.
//

@testable import FinchApp
import SnapshotTesting
import XCTest

final class CompareCommandTests: TestCase {
    func testCommandName() {
        let command = CompareCommand(appGenerator: { _, _, _ in .mock() })

        XCTAssertEqual(command.name, "compare")
    }
}
