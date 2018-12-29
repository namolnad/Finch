//
//  OutputTests.swift
//  DiffFormatterTests
//
//  Created by Dan Loman on 8/16/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import XCTest
@testable import DiffFormatter
import SnapshotTesting

final class OutputTests: XCTestCase {
    func testOutputGenerator() {
        let outputGenerator: Utilities.OutputGenerator = .init(
            configuration: .mock,
            rawDiff: Utilities.inputMock,
            version: "6.13.0",
            releaseManager: Configuration.mock.contributors.first
        )

        assertSnapshot(
            matching: outputGenerator.generateOutput(),
            as: .dump
        )
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

        assertSnapshot(
            matching: outputGenerator.generateOutput(),
            as: .dump
        )
    }

    func testLineComponentParsing() {
        let sample = "&&&5a544059e165f0703843d1c6c509cc853ad6afa4&&& - @@@[tag1][tag2] fixing something somewhere (#1234)@@@###author@email.com###"

        assertSnapshot(
            matching: Section.Line.Components(
                rawLine: sample,
                configuration: .mock
            ),
            as: .dump
        )

        let sample2 = "&&&5a544059e165f0703843d1c6c509cc853ad6afa4&&& - @@@[tag1]fixing something somewhere@@@###author+1234@email.com###"

        assertSnapshot(
            matching: Section.Line.Components(
                rawLine: sample2,
                configuration: .mock
            ),
            as: .dump
        )
    }
}
