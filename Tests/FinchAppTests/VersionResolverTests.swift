@testable import FinchApp
import SnapshotTesting
import XCTest

final class VersionResolverTests: TestCase {
    func testDefault() {
        let (old, new) = try! VersionsResolver().versions(from: "6.12.1 6.38.0")

        XCTAssertEqual(old, .init(major: 6, minor: 12, patch: 1))
        XCTAssertEqual(new, .init(major: 6, minor: 38, patch: 0))
    }

    func testReverseOrder() {
        let (old, new) = try! VersionsResolver().versions(from: "6.38.0 6.12.1")

        XCTAssertEqual(old, .init(major: 6, minor: 12, patch: 1))
        XCTAssertEqual(new, .init(major: 6, minor: 38, patch: 0))
    }

    func testReverseSeparateMajor() {
        let (old, new) = try! VersionsResolver().versions(from: "7.38.0 6.12.1")

        XCTAssertEqual(old, .init(major: 6, minor: 12, patch: 1))
        XCTAssertEqual(new, .init(major: 7, minor: 38, patch: 0))
    }

    func testPreReleaseAndBuildMetaData() {
        let (old, new) = try! VersionsResolver().versions(from: "6.12.1-alpha.frankenstein+12.345 7.38.0")

        XCTAssertEqual(
            old,
            .init(
                major: 6,
                minor: 12,
                patch: 1,
                prereleaseIdentifiers: ["alpha", "frankenstein"],
                buildMetadataIdentifiers: ["12", "345"]
            )
        )
        XCTAssertEqual(new, .init(major: 7, minor: 38, patch: 0))
    }

    func testFailureTooManyArguments() {
        // error.localizedDescription output differs between platforms
        guard TestHelper.isMacOS else {
            return
        }

        do {
            _ = try VersionsResolver().versions(from: "6.0.2 6.4.3 6.12.1")
        } catch {
            assertSnapshot(matching: error.localizedDescription, as: .dump)
        }
    }

    func testFailureInvalidArguments() {
        // error.localizedDescription output differs between platforms
        guard TestHelper.isMacOS else {
            return
        }

        do {
            _ = try VersionsResolver().versions(from: "blah 6.12.1")
        } catch {
            assertSnapshot(matching: error.localizedDescription, as: .dump)
        }
    }
}
