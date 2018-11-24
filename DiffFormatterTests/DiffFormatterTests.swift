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

    func testArgumentRouter() {
        let router = ArgumentRouter(app: .mock, configuration: .mock)

        let routableArgs: [String] = ["6.12.1", "6.13.0", "--git-diff=\(inputMock)"]
        let scheme = ArgumentScheme(arguments: routableArgs)

        XCTAssertTrue(router.route(argScheme: scheme) == .handled)

        XCTAssertTrue(router.route(argScheme: .mock) == .notHandled)
    }

    func testOutputGenerator() {
        let outputGenerator: Utilities.OutputGenerator = .init(
            configuration: .mock,
            rawDiff: inputMock,
            version: "6.13.0",
            releaseManager: Configuration.mock.contributors.first
        )

        XCTAssertEqual(outputGenerator.generatedOutput(), Utilities.mockOutput)
    }

    func testCustomDelimiterOutput() {
        let customPath = "custom_delimiter_config"

        let processInfoMock = ProcessInfoMock(arguments: [], environment: ["DIFF_FORMATTER_CONFIG": customPath])
        let fileManagerMock = FileManagerMock(customConfigPath: customPath)

        let outputGenerator: Utilities.OutputGenerator = .init(
            configuration: Configurator(processInfo: processInfoMock, argScheme: .mock, fileManager: fileManagerMock).configuration,
            rawDiff: inputMock,
            version: "6.13.0",
            releaseManager: Configuration.mock.contributors.first
        )

        XCTAssertEqual(outputGenerator.generatedOutput(), Utilities.mockCustomDelimiterOutput)
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

fileprivate extension ProcessInfo {
    static let mock: ProcessInfo = ProcessInfoMock(arguments: [], environment: [:])
}

fileprivate extension FileManager {
    static let mock: FileManager = FileManagerMock()
}

fileprivate extension Configuration {
    // TODO: - Shouldn't rely on configurator for mock
    static let mock: Configuration = Configurator(processInfo: .mock, argScheme: .mock, fileManager: .mock).configuration
}

fileprivate extension ArgumentScheme {
    static let mock: ArgumentScheme = ArgumentScheme(oldVersion: nil, newVersion: nil, args: [])
}

fileprivate extension App {
    static let mock: App = .init(buildNumber: "12345", name: "DiffFormatter", version: "1.0.1")
}

fileprivate extension Utilities {
    static let mockOutput: String = """

# 6.13.0

### Release Manager

 - @Jony.Ive

### Features
 - |tests| fix order snapshots — [PR #1018](https://github.com/citadel-of-ricks/C-137/pull/1018) — @Rick.Sanchez
 - |search| consolidate searchBar cornerRadius to 4, increase autocomplete-v3 term height — [PR #1011](https://github.com/citadel-of-ricks/C-137/pull/1011) — @Elvis.Presley
 - |rollbar| update to v1.0.0 final — [PR #1007](https://github.com/citadel-of-ricks/C-137/pull/1007) — @Elvis.Presley
 - |push-notificatons| Request for permission after user places an order with 90 day re-prompt — [PR #1024](https://github.com/citadel-of-ricks/C-137/pull/1024) — @Jony.Ive
 - |express-placement| build error fix — [PR #1025](https://github.com/citadel-of-ricks/C-137/pull/1025) — @Jony.Ive
 - |express-placement| additional clean-up for analytics and bugs — [PR #1021](https://github.com/citadel-of-ricks/C-137/pull/1021) — @Jony.Ive
 - |codable| better supported for AnyEncodables — [PR #1022](https://github.com/citadel-of-ricks/C-137/pull/1022) — @Elvis.Presley
 - |carthage| move google places to internal carthage — [PR #1008](https://github.com/citadel-of-ricks/C-137/pull/1008) — @Elvis.Presley
 - |autocomplete-v3| add analytics — [PR #1030](https://github.com/citadel-of-ricks/C-137/pull/1030) — @Elvis.Presley
 - |analytics| Current production express placements are missing subscription_id in express_start.purchase tracking events — [PR #1020](https://github.com/citadel-of-ricks/C-137/pull/1020) — @Jony.Ive
 - Update all express placements to one screen — [PR #975](https://github.com/citadel-of-ricks/C-137/pull/975) — @Jony.Ive
 - Syncing express params across checkout modules — [PR #1016](https://github.com/citadel-of-ricks/C-137/pull/1016) — @Rick.Sanchez
 - Order status V2.5 — [PR #988](https://github.com/citadel-of-ricks/C-137/pull/988) — @Elvis.Presley
 - Autocomplete V3 — [PR #1004](https://github.com/citadel-of-ricks/C-137/pull/1004) — @Elvis.Presley

### Bug Fixes
 - |bug| Don't show express placement every cold start — [PR #1019](https://github.com/citadel-of-ricks/C-137/pull/1019) — @Jony.Ive
 - |bug fix| minor bug fixes for cubs/pbi — [PR #1010](https://github.com/citadel-of-ricks/C-137/pull/1010) — @Elvis.Presley
 - |bug fix| fix LossyCodableArray — [PR #1017](https://github.com/citadel-of-ricks/C-137/pull/1017) — @Rick.Sanchez

### Platform Improvements
 - background actions — [PR #955](https://github.com/citadel-of-ricks/C-137/pull/955)

### Timeline
- Begin development:
- Feature cut-off / Start of bake / dogfooding:
- Submission:
- Release (expected):
- Release (actual):

"""

    static let mockCustomDelimiterOutput: String = """

# 6.13.0

### Release Manager

 - @Jony.Ive

### Features
 - **❲**tests**❳** fix order snapshots — [PR #1018](https://github.com/citadel-of-ricks/C-137/pull/1018) — @Rick.Sanchez
 - **❲**search**❳** consolidate searchBar cornerRadius to 4, increase autocomplete-v3 term height — [PR #1011](https://github.com/citadel-of-ricks/C-137/pull/1011) — @Elvis.Presley
 - **❲**rollbar**❳** update to v1.0.0 final — [PR #1007](https://github.com/citadel-of-ricks/C-137/pull/1007) — @Elvis.Presley
 - **❲**push-notificatons**❳** Request for permission after user places an order with 90 day re-prompt — [PR #1024](https://github.com/citadel-of-ricks/C-137/pull/1024) — @Jony.Ive
 - **❲**express-placement**❳** build error fix — [PR #1025](https://github.com/citadel-of-ricks/C-137/pull/1025) — @Jony.Ive
 - **❲**express-placement**❳** additional clean-up for analytics and bugs — [PR #1021](https://github.com/citadel-of-ricks/C-137/pull/1021) — @Jony.Ive
 - **❲**codable**❳** better supported for AnyEncodables — [PR #1022](https://github.com/citadel-of-ricks/C-137/pull/1022) — @Elvis.Presley
 - **❲**carthage**❳** move google places to internal carthage — [PR #1008](https://github.com/citadel-of-ricks/C-137/pull/1008) — @Elvis.Presley
 - **❲**autocomplete-v3**❳** add analytics — [PR #1030](https://github.com/citadel-of-ricks/C-137/pull/1030) — @Elvis.Presley
 - **❲**analytics**❳** Current production express placements are missing subscription_id in express_start.purchase tracking events — [PR #1020](https://github.com/citadel-of-ricks/C-137/pull/1020) — @Jony.Ive
 - Update all express placements to one screen — [PR #975](https://github.com/citadel-of-ricks/C-137/pull/975) — @Jony.Ive
 - Syncing express params across checkout modules — [PR #1016](https://github.com/citadel-of-ricks/C-137/pull/1016) — @Rick.Sanchez
 - Order status V2.5 — [PR #988](https://github.com/citadel-of-ricks/C-137/pull/988) — @Elvis.Presley
 - Autocomplete V3 — [PR #1004](https://github.com/citadel-of-ricks/C-137/pull/1004) — @Elvis.Presley

### Bug Fixes
 - **❲**bug**❳** Don't show express placement every cold start — [PR #1019](https://github.com/citadel-of-ricks/C-137/pull/1019) — @Jony.Ive
 - **❲**bug fix**❳** minor bug fixes for cubs/pbi — [PR #1010](https://github.com/citadel-of-ricks/C-137/pull/1010) — @Elvis.Presley
 - **❲**bug fix**❳** fix LossyCodableArray — [PR #1017](https://github.com/citadel-of-ricks/C-137/pull/1017) — @Rick.Sanchez

### Platform Improvements
 - **❲**platform**❳** background actions — [PR #955](https://github.com/citadel-of-ricks/C-137/pull/955) — @Elvis.Presley

### Timeline
- Begin development:
- Feature cut-off / Start of bake / dogfooding:
- Submission:
- Release (expected):
- Release (actual):

"""
}
