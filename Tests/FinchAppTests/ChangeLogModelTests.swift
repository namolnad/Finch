//
//  ChangeLogModelTests.swift
//  FinchTests
//
//  Created by Dan Loman on 8/16/18.
//  Copyright © 2018 DHL. All rights reserved.
//

@testable import FinchApp
import FinchCore
import SnapshotTesting
import XCTest

final class ChangeLogModelTests: TestCase {
    private var model: ChangeLogModel {
        return ChangeLogModel(
            resolver: VersionsResolverMock(),
            service: ChangeLogInfoServiceMock()
        )
    }

    func testDefaultOutput() {
        let output = try! model.changeLog(
            options: options(gitLog: defaultInputMock),
            app: .mock(),
            env: [:]
        )

        assertSnapshot(
            matching: output,
            as: .dump
        )
    }

    func testCherryPickedSectionOutput() {
        let output = try! model.changeLog(
            options: options(gitLog: cherryPickedInputMock),
            app: .mock(),
            env: [:]
        )

        assertSnapshot(
            matching: output,
            as: .dump
        )
    }

    func testExcludedSectionOutput() {
        let output = try! model.changeLog(
            options: options(gitLog: cherryPickedInputMock),
            app: .mock(configuration: .mockExcludedSection),
            env: [:]
        )

        assertSnapshot(
            matching: output,
            as: .dump
        )
    }

    func testCustomDelimiterOutput() {
        let customPath = "custom_delimiter_config"

        let fileManagerMock = FileManagerMock(customConfigPath: customPath)

        let configuration = Configurator(
            options: .blank,
            meta: .mock,
            environment: ["FINCH_CONFIG": customPath],
            fileManager: fileManagerMock
        ).configuration

        let output = try! model.changeLog(
            options: options(gitLog: defaultInputMock),
            app: .mock(configuration: configuration),
            env: [:]
        )

        assertSnapshot(
            matching: output,
            as: .dump
        )
    }

    func testOutputWithHeader() {
        let output = try! model.changeLog(
            options: options(gitLog: defaultInputMock),
            app: .mock(configuration: .mockWithHeader),
            env: [:]
        )

        assertSnapshot(
            matching: output,
            as: .dump
        )
    }

    func testVersionResolution() {
        let versions = try! model.versions(app: .mock(), env: [:])

        XCTAssertEqual(versions.old, .init(0, 0, 13))
        XCTAssertEqual(versions.new, .init(6, 13, 0))
    }

    func testRequiredTags() {
        let output = try! model.changeLog(
            options: options(gitLog: multipleTagsMock),
            app: .mock(configuration: .mockRequiredTags),
            env: [:]
        )

        assertSnapshot(
            matching: output,
            as: .dump
        )
    }

    private func options(gitLog: String) -> CompareCommand.Options {
        return .init(
            versions: (.init(0, 0, 1), .init(6, 13, 0)),
            buildNumber: nil,
            gitLog: gitLog,
            normalizeTags: false,
            noFetch: true,
            noShowVersion: false,
            releaseManager: Configuration.mock.contributorsConfig.contributors.first?.emails.first,
            toPasteBoard: false
        )
    }
}

extension App {
    static func mock(configuration: Configuration = .mock) -> App {
        return .init(
            configuration: configuration,
            meta: .mock,
            options: .mock
        )
    }
}

struct ChangeLogInfoServiceMock: ChangeLogInfoServiceType {
    func versionsString(app: App, env: Environment) throws -> String {
        return "0.0.1 6.13.0"
    }

    func buildNumber(options: CompareCommand.Options, app: App, env: Environment) throws -> String? {
        guard let buildNumber = options.buildNumber else {
            return nil
        }

        return buildNumber
    }

    func changeLog(options: CompareCommand.Options, app: App, env: Environment) throws -> String {
        guard let log = options.gitLog else {
            return defaultInputMock
        }

        return log
    }
}

struct VersionsResolverMock: VersionsResolving {
    func versions(from versionString: String) throws -> (old: Version, new: Version) {
        return (.init(0, 0, 13), .init(6, 13, 0))
    }
}
