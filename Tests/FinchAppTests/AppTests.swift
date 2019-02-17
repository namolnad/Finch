//
//  AppTests.swift
//  FinchAppTests
//
//  Created by Dan Loman on 2/16/19.
//

import XCTest
@testable import FinchApp

final class AppTests: XCTestCase {
    func testOutput() {
        let outputMock = OutputMock()

        let app = App(
            configuration: .mock,
            meta: .mock,
            options: .mock,
            output: outputMock
        )

        XCTAssertNil(outputMock.outputs.last)

        app.print("hello")

        XCTAssertEqual(outputMock.outputs.last, "hello")
    }
}
