//
//  AppRunnerTests.swift
//  FinchAppTests
//
//  Created by Dan Loman on 2/16/19.
//

@testable import FinchApp
import SnapshotTesting
import XCTest

final class AppRunnerTests: TestCase {
    func testRunCompare() {
        let outputMock = OutputMock()

        AppRunner(
            environment: [:],
            meta: .mock,
            output: outputMock
        ).run(arguments: ["finch", "compare", "--git-log", defaultInputMock, "--versions", "6.20.0", "5.3.0", "--build-number", "612"])

        assertSnapshot(matching: outputMock.outputs, as: .dump)
    }

    func testRunConfigExample() {
        let outputMock = OutputMock()

        AppRunner(
            environment: [:],
            meta: .mock,
            output: outputMock
        ).run(arguments: ["finch", "config", "show-example"])

        assertSnapshot(matching: outputMock.outputs, as: .dump)
    }

    func testPrintAppVersion() {
        let outputMock = OutputMock()

        AppRunner(
            environment: [:],
            meta: .mock,
            output: outputMock
        ).run(arguments: ["finch", "--version"])

        XCTAssert(outputMock.outputs.first!.contains("Finch"))
    }
}
