@testable import FinchApp
import FinchCore
import SnapshotTesting
import Version
import XCTest

final class ChangeLogModelTests: TestCase {
    private var model: ChangeLogModel {
        ChangeLogModel(
            resolver: VersionsResolverMock(),
            service: ChangeLogInfoServiceMock()
        )
    }

    func testDefaultOutput() {
        let output = try! model.changeLog(
            options: options(gitLog: defaultInputMock),
            app: .mock()
        )

        assertSnapshot(
            matching: output,
            as: .dump
        )
    }

    func testCherryPickedSectionOutput() {
        let output = try! model.changeLog(
            options: options(gitLog: cherryPickedInputMock),
            app: .mock()
        )

        assertSnapshot(
            matching: output,
            as: .dump
        )
    }

    func testExcludedSectionOutput() {
        let output = try! model.changeLog(
            options: options(gitLog: cherryPickedInputMock),
            app: .mock(configuration: .mockExcludedSection)
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
            configPath: nil,
            projectDir: "current",
            meta: .mock,
            environment: ["FINCH_CONFIG": customPath],
            fileManager: fileManagerMock
        ).configuration

        let output = try! model.changeLog(
            options: options(gitLog: defaultInputMock),
            app: .mock(configuration: configuration)
        )

        assertSnapshot(
            matching: output,
            as: .dump
        )
    }

    func testOutputWithHeader() {
        let output = try! model.changeLog(
            options: options(gitLog: defaultInputMock),
            app: .mock(configuration: .mockWithHeader)
        )

        assertSnapshot(
            matching: output,
            as: .dump
        )
    }

    func testVersionResolution() {
        let versions = try! model.versions(app: .mock())

        XCTAssertEqual(versions.old, .init(0, 0, 13))
        XCTAssertEqual(versions.new, .init(6, 13, 0))
    }

    func testRequiredTags() {
        let output = try! model.changeLog(
            options: options(
                gitLog: multipleTagsMock,
                requiredTags: ["app-store"],
                showReleaseManager: false,
                showVersion: false
            ),
            app: .mock(configuration: .mockRequiredTags)
        )

        assertSnapshot(
            matching: output,
            as: .dump
        )
    }

    func testUseNewlineChar() {
        let output = try! model.changeLog(
            options: options(
                gitLog: multipleTagsMock,
                requiredTags: ["app-store"],
                showReleaseManager: false,
                showVersion: false,
                useNewlineChar: true
            ),
            app: .mock(configuration: .mockRequiredTags)
        )

        assertSnapshot(
            matching: output,
            as: .dump
        )
    }

    private func options(
        gitLog: String,
        requiredTags: [String] = [],
        showReleaseManager: Bool = true,
        showVersion: Bool = true,
        useNewlineChar: Bool = false
    ) -> CompareCommand.Options {
        let contributorEmail = Configuration.mock.contributorsConfig
            .contributors.first!.emails.first!

        return .init(
            versions: .init(old: .init(0, 0, 1), new: .init(6, 13, 0)),
            buildNumber: nil,
            gitLog: gitLog,
            normalizeTags: false,
            noFetch: true,
            noShowVersion: !showVersion,
            releaseManager: showReleaseManager ? contributorEmail : nil,
            requiredTags: Set(requiredTags),
            useNewlineChar: useNewlineChar
        )
    }
}

extension App {
    static func mock(configuration: Configuration = .mock) -> App {
        .init(
            configuration: configuration,
            meta: .mock
        )
    }
}

struct ChangeLogInfoServiceMock: ChangeLogInfoServiceType {
    func versionsString(app: App) throws -> String {
        "0.0.1 6.13.0"
    }

    func buildNumber(options: CompareCommand.Options, app: App) throws -> String? {
        guard let buildNumber = options.buildNumber else {
            return nil
        }

        return buildNumber
    }

    func changeLog(options: CompareCommand.Options, app: App) throws -> String {
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
