//
//  OutputTests.swift
//  OutputTests
//
//  Created by Dan Loman on 8/16/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import XCTest
@testable import DiffFormatter

final class OutputTests: XCTestCase {
    func testOutputGenerator() {
        let outputGenerator: Utilities.OutputGenerator = .init(
            configuration: .mock,
            rawDiff: Utilities.inputMock,
            version: "6.13.0",
            releaseManager: Configuration.mock.contributors.first
        )

        XCTAssertEqual(outputGenerator.generateOutput(), Utilities.mockOutput)
    }

    func testCustomDelimiterOutput() {
        let customPath = "custom_delimiter_config"

        let processInfoMock = ProcessInfoMock(arguments: [], environment: ["DIFF_FORMATTER_CONFIG": customPath])
        let fileManagerMock = FileManagerMock(customConfigPath: customPath)

        let outputGenerator: Utilities.OutputGenerator = .init(
            configuration: Configurator(processInfo: processInfoMock, argScheme: .mock, fileManager: fileManagerMock).configuration,
            rawDiff: Utilities.inputMock,
            version: "6.13.0",
            releaseManager: Configuration.mock.contributors.first
        )

        XCTAssertEqual(outputGenerator.generateOutput(), Utilities.mockCustomDelimiterOutput)
    }

    func testLineComponentParsing() {
        let sample = "&&&5a544059e165f0703843d1c6c509cc853ad6afa4&&& - @@@[tag1][tag2] fixing something somewhere (#1234)@@@###author@email.com###"

        let component = Section.Line.Components(rawLine: sample, configuration: .mock)

        XCTAssert(component.contributorEmail == "author@email.com")
        XCTAssert(component.sha == "5a544059e165f0703843d1c6c509cc853ad6afa4")
        XCTAssert(component.message == "fixing something somewhere")
        XCTAssert(component.pullRequestNumber == 1234)
        XCTAssert(component.tags == ["tag1", "tag2"])

        let sample2 = "&&&5a544059e165f0703843d1c6c509cc853ad6afa4&&& - @@@[tag1]fixing something somewhere@@@###author+1234@email.com###"

        let component2 = Section.Line.Components(rawLine: sample2, configuration: .mock)

        XCTAssert(component2.contributorEmail == "author+1234@email.com")
        XCTAssert(component2.sha == "5a544059e165f0703843d1c6c509cc853ad6afa4")
        XCTAssert(component2.message == "fixing something somewhere")
        XCTAssertNil(component2.pullRequestNumber)
        XCTAssert(component2.tags == ["tag1"])
    }
}
