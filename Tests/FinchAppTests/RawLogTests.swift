@testable import FinchCore
import XCTest

final class RawLogTests: TestCase {
    private let sha = "5a544059e165f0703843d1c6c509cc853ad6afa4"

    func testSingleEntryCommit() {
        let line = rawLine(message: "[tag] fixing something somewhere (#1234)")

        XCTAssertEqual(entryLines(from: line), [line])
    }

    func testTaggedLinesEachBecomeAnEntry() {
        let lines = entryLines(
            from: rawLine(
                message: """
                [fixed] Fixed a really bad bug
                [added] Added a new feature
                """
            )
        )

        XCTAssertEqual(
            lines,
            [
                rawLine(message: "[fixed] Fixed a really bad bug"),
                rawLine(message: "[added] Added a new feature")
            ]
        )
    }

    func testBlankLineSeparatedEntries() {
        let lines = entryLines(
            from: rawLine(
                message: """
                [fixed] Fixed a really bad bug

                [added] Added a new feature
                """
            )
        )

        XCTAssertEqual(
            lines,
            [
                rawLine(message: "[fixed] Fixed a really bad bug"),
                rawLine(message: "[added] Added a new feature")
            ]
        )
    }

    /// The commit's pull request is carried by each of its entries
    func testPullRequestReferencePropagation() {
        let lines = entryLines(
            from: rawLine(
                message: """
                [fixed] Fixed a really bad bug (#1234)
                [added] Added a new feature
                [tests] Added a test (#5678)
                """
            )
        )

        XCTAssertEqual(
            lines,
            [
                rawLine(message: "[fixed] Fixed a really bad bug (#1234)"),
                rawLine(message: "[added] Added a new feature (#1234)"),
                rawLine(message: "[tests] Added a test (#5678)")
            ]
        )
    }

    /// An untagged line extends the entry above it, as `%s` would have joined it
    func testUntaggedLineExtendsPrecedingEntry() {
        let lines = entryLines(
            from: rawLine(
                message: """
                [fixed] Fixed a really bad bug
                which had been around for a while
                """
            )
        )

        XCTAssertEqual(
            lines,
            [rawLine(message: "[fixed] Fixed a really bad bug which had been around for a while")]
        )
    }

    /// Prose bodies are not changelog entries and are left out
    func testUntaggedBodyIsDropped() {
        let lines = entryLines(
            from: rawLine(
                message: """
                [fixed] Fixed a really bad bug (#1234)

                The fix restores the behavior which had regressed in 6.12.0.

                * dropped the legacy path
                * added a regression test
                """
            )
        )

        XCTAssertEqual(lines, [rawLine(message: "[fixed] Fixed a really bad bug (#1234)")])
    }

    /// An untagged subject remains a single entry, wildcard section included
    func testUntaggedSubject() {
        let lines = entryLines(
            from: rawLine(
                message: """
                Order status V2.5 (#988)

                [bug] fix LossyCodableArray
                """
            )
        )

        XCTAssertEqual(
            lines,
            [
                rawLine(message: "Order status V2.5 (#988)"),
                rawLine(message: "[bug] fix LossyCodableArray (#988)")
            ]
        )
    }

    /// Left/right markers apply to every entry derived from the commit
    func testMarkerPrefixIsPreserved() {
        let lines = entryLines(
            from: rawLine(
                prefix: "< ",
                message: """
                [fixed] Fixed a really bad bug
                [added] Added a new feature
                """
            )
        )

        XCTAssertEqual(
            lines,
            [
                rawLine(prefix: "< ", message: "[fixed] Fixed a really bad bug"),
                rawLine(prefix: "< ", message: "[added] Added a new feature")
            ]
        )
    }

    func testUnparseableInputIsPassedThrough() {
        let input = "not a commit"

        XCTAssertEqual(entryLines(from: input), [input])
    }

    private func entryLines(from rawLog: String) -> [String] {
        RawLog.entryLines(from: rawLog, configuration: .mock)
    }

    private func rawLine(prefix: String = "", message: String) -> String {
        "\(prefix)&&&\(sha)&&& - @@@\(message)@@@###author@email.com###"
    }
}
