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
        let command = CompareCommand(env: [:], meta: .mock, output: OutputMock())

        XCTAssertEqual(command.verb, "compare")
    }
}
