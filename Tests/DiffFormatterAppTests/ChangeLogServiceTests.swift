//
//  ChangeLogServiceTests.swift
//  DiffFormatterTests
//
//  Created by Dan Loman on 8/16/18.
//  Copyright © 2018 DHL. All rights reserved.
//

@testable import DiffFormatterApp
import DiffFormatterCore
import SnapshotTesting
import XCTest

final class ChangeLogServiceTests: XCTestCase {

    private var service: ChangeLogService {
        return ChangeLogService(
            buildNumberProvider: BuildNumberProvidingMock(),
            logProvider: LogProvidingMock()
        )
    }

    func testDefaultOutput() {
        let output = try! service.changeLog(
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
        let output = try! service.changeLog(
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
        let output = try! service.changeLog(
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
            environment: ["DIFFFORMATTER_CONFIG": customPath],
            fileManager: fileManagerMock
        ).configuration

        let output = try! service.changeLog(
            options: options(gitLog: defaultInputMock),
            app: .mock(configuration: configuration),
            env: [:]
        )

        assertSnapshot(
            matching: output,
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

    private func options(gitLog: String) -> GenerateCommand.Options {
        return .init(
            versions: (.init(0, 0, 1), .init(6, 13, 0)),
            buildNumber: nil,
            gitLog: gitLog,
            noFetch: true,
            noShowVersion: false,
            releaseManager: Configuration.mock.contributors.first?.email,
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

struct BuildNumberProvidingMock: BuildNumberProviding {
    func buildNumber(options: GenerateCommand.Options, app: App, env: Environment) throws -> String? {
        guard let buildNumber = options.buildNumber else {
            return nil
        }

        return buildNumber
    }
}

struct LogProvidingMock: LogProviding {
    func log(options: GenerateCommand.Options, app: App, env: Environment) throws -> String {
        guard let log = options.gitLog else {
            return defaultInputMock
        }

        return log
    }
}
