//
//  OutputTests.swift
//  DiffFormatterTests
//
//  Created by Dan Loman on 8/16/18.
//  Copyright © 2018 DHL. All rights reserved.
//

@testable import DiffFormatterApp
import DiffFormatterCore
import SnapshotTesting
import XCTest

final class OutputTests: XCTestCase {
    func testDefaultOutput() {
        let outputGenerator: OutputGenerator = .init(
            configuration: .mock,
            rawDiff: inputMock,
            version: "6.13.0",
            releaseManager: Configuration.mock.contributors.first
        )

        assertSnapshot(
            matching: outputGenerator.generateOutput(),
            as: .dump
        )
    }

    func testExcludedSectionOutput() {
        let outputGenerator: OutputGenerator = .init(
            configuration: .mockExcludedSection,
            rawDiff: inputMock,
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

        let processInfoMock = ProcessInfoMock(arguments: [], environment: ["DIFFFORMATTER_CONFIG": customPath])
        let fileManagerMock = FileManagerMock(customConfigPath: customPath)

        let outputGenerator: OutputGenerator = .init(
            configuration: Configurator(
                processInfo: processInfoMock,
                argScheme: .mock,
                fileManager: fileManagerMock
                ).configuration,
            rawDiff: inputMock,
            version: "6.13.0",
            releaseManager: Configuration.mock.contributors.first
        )

        assertSnapshot(
            matching: outputGenerator.generateOutput(),
            as: .dump
        )
    }

    func testLineComponentParsing() {
        let sha = "5a544059e165f0703843d1c6c509cc853ad6afa4"

        let sample = "&&&\(sha)&&& - @@@[tag1][tag2] fixing something somewhere (#1234)@@@###author@email.com###"

        assertSnapshot(
            matching: LineComponents(
                rawLine: sample,
                configuration: .mock
            ),
            as: .dump
        )

        let sample2 = "&&&\(sha)&&& - @@@[tag1]fixing something somewhere@@@###author+1234@email.com###"

        assertSnapshot(
            matching: LineComponents(
                rawLine: sample2,
                configuration: .mock
            ),
            as: .dump
        )
    }
}
