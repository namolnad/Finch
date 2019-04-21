//
//  AppTests.swift
//  FinchAppTests
//
//  Created by Dan Loman on 2/16/19.
//

@testable import FinchApp
import XCTest

final class AppTests: TestCase {
    func testOutput() {
        let outputMock = OutputMock()

        let app = App(
            configuration: .mock,
            meta: .mock,
            output: outputMock
        )

        XCTAssertNil(outputMock.outputs.last)

        app.print("hello")

        XCTAssertEqual(outputMock.outputs.last, "hello")
    }
}
