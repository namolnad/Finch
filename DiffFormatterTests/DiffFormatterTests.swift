//
//  DiffFormatterTests.swift
//  DiffFormatterTests
//
//  Created by Dan Loman on 8/16/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import XCTest
@testable import DiffFormatter

class DiffFormatterTests: XCTestCase {
    func testConfigurator() {
        let configurator = Configurator(processInfo: .init())
    }

    func testRouter() {
        let router = ArgumentRouter(configuration: .default)

        router.route(arguments: [testInput])
    }

    func testOutput() {
        let outputGenerator = OutputGenerator(
            configuration: .default,
            rawDiff: testInput,
            version: "6.12.0",
            releaseManager: nil
        )

        print(outputGenerator.generatedOutput())
    }
}
