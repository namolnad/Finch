@testable import FinchCore
import XCTest

final class CommitParserTests: XCTestCase {
    private let conventional: CommitParser = .init(configuration: .mockConventional)
    private let delimited: CommitParser = .init(configuration: .mock)

    func testConventionalType() {
        let components = conventional.components(of: "feat: add teleportation")

        XCTAssertEqual(components.tags, ["feat"])
        XCTAssertEqual(components.description, "add teleportation")
    }

    func testConventionalScopes() {
        let components = conventional.components(of: "fix(parser, cli): handle empty input (#42)")

        XCTAssertEqual(components.tags, ["fix", "parser", "cli"])
        XCTAssertEqual(components.description, "handle empty input")
    }

    /// Breaking leads the tags so that it wins section assignment over the type
    func testConventionalBreakingMarker() {
        let components = conventional.components(of: "feat(api)!: drop v1")

        XCTAssertEqual(components.tags, ["breaking", "feat", "api"])
        XCTAssertEqual(components.description, "drop v1")
    }

    func testConventionalBreakingFooter() {
        let components = conventional.components(of: "BREAKING CHANGE: the express_start event is gone")

        XCTAssertEqual(components.tags, ["breaking"])
        XCTAssertEqual(components.description, "the express_start event is gone")
    }

    /// An untagged subject is still an entry, and lands in the wildcard section
    func testConventionalUntagged() {
        let components = conventional.components(of: "Order status V2.5 (#988)")

        XCTAssertEqual(components.tags, [])
        XCTAssertEqual(components.description, "Order status V2.5")
    }

    /// Prose containing a colon is not a conventional type
    func testProseWithColonIsNotATag() {
        for message in ["Note: this is prose", "Fixes: #123", "See also: the docs"] {
            XCTAssertEqual(conventional.components(of: message).tags, [], message)
            XCTAssertFalse(conventional.opensEntry(message), message)
        }
    }

    func testConventionalOpensEntry() {
        XCTAssertTrue(conventional.opensEntry("fix: a thing"))
        XCTAssertTrue(conventional.opensEntry("feat(scope)!: a thing"))
        XCTAssertTrue(conventional.opensEntry("BREAKING CHANGE: a thing"))
        XCTAssertFalse(conventional.opensEntry("* a bullet"))
        XCTAssertFalse(conventional.opensEntry("[fixed] a delimited tag"))
    }

    func testDelimitedStyleIsUnchanged() {
        let components = delimited.components(of: "[bug][app-store] fix the thing (#1010)")

        XCTAssertEqual(components.tags, ["bug", "app-store"])
        XCTAssertEqual(components.description, "fix the thing")
    }

    func testDelimitedOpensEntry() {
        XCTAssertTrue(delimited.opensEntry("[fixed] a thing"))
        XCTAssertFalse(delimited.opensEntry("fix: a conventional tag"))
    }
}
