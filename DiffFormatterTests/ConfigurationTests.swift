//
//  ConfigurationTests.swift
//  DiffFormatterTests
//
//  Created by Dan Loman on 12/28/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import XCTest
@testable import DiffFormatter

final class ConfigurationTests: XCTestCase {
    func testConfigurator() {
        let configurator = Configurator(processInfo: .mock, argScheme: .mock, fileManager: .mock)

        let contributors = configurator.configuration.contributors
        XCTAssertEqual(contributors.count, 3)
        XCTAssertEqual(contributors[1].email, "long_live_the_citadel@rick.com")
        XCTAssertEqual(contributors[2].handle, "Elvis.Presley")
        XCTAssertEqual(contributors[2].email, "elvis1935+still-alive@theking.com")

        XCTAssertEqual(configurator.configuration.contributorHandlePrefix, "@")

        let sectionInfos = configurator.configuration.sectionInfos
        XCTAssertEqual(sectionInfos.count, 3)
        XCTAssertEqual(sectionInfos[1].title, "Bug Fixes")
        XCTAssertEqual(sectionInfos[2].tags.count, 4)

        XCTAssertNotNil(configurator.configuration.footer)

        let delimiterConfig = configurator.configuration.delimiterConfig
        XCTAssertEqual(delimiterConfig.input.left, "[")
        XCTAssertEqual(delimiterConfig.input.right, "]")
        XCTAssertEqual(delimiterConfig.output.right, "|")
        XCTAssertEqual(delimiterConfig.output.right, "|")
    }
}
