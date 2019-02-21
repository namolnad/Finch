import XCTest

extension AppRunnerTests {
    static let __allTests = [
        ("testPrintAppVersion", testPrintAppVersion),
        ("testRunCompare", testRunCompare),
        ("testRunConfigExample", testRunConfigExample),
    ]
}

extension AppTests {
    static let __allTests = [
        ("testOutput", testOutput),
    ]
}

extension ChangeLogModelTests {
    static let __allTests = [
        ("testCherryPickedSectionOutput", testCherryPickedSectionOutput),
        ("testCustomDelimiterOutput", testCustomDelimiterOutput),
        ("testDefaultOutput", testDefaultOutput),
        ("testExcludedSectionOutput", testExcludedSectionOutput),
        ("testOutputWithHeader", testOutputWithHeader),
        ("testVersionResolution", testVersionResolution),
    ]
}

extension CommandRegistryTests {
    static let __allTests = [
        ("testParsingCompare", testParsingCompare),
        ("testParsingCompareManyOptions", testParsingCompareManyOptions),
        ("testParsingVersion", testParsingVersion),
    ]
}

extension CompareCommandTests {
    static let __allTests = [
        ("testCommandName", testCommandName),
    ]
}

extension ConfiguratorTests {
    static let __allTests = [
        ("testDefault", testDefault),
        ("testProjectDirOption", testProjectDirOption),
    ]
}

extension LineTests {
    static let __allTests = [
        ("testLineComponentParsing", testLineComponentParsing),
    ]
}

extension VersionResolverTests {
    static let __allTests = [
        ("testDefault", testDefault),
        ("testFailureInvalidArguments", testFailureInvalidArguments),
        ("testFailureTooManyArguments", testFailureTooManyArguments),
        ("testPreReleaseAndBuildMetaData", testPreReleaseAndBuildMetaData),
        ("testReverseOrder", testReverseOrder),
        ("testReverseSeparateMajor", testReverseSeparateMajor),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AppRunnerTests.__allTests),
        testCase(AppTests.__allTests),
        testCase(ChangeLogModelTests.__allTests),
        testCase(CommandRegistryTests.__allTests),
        testCase(CompareCommandTests.__allTests),
        testCase(ConfiguratorTests.__allTests),
        testCase(LineTests.__allTests),
        testCase(VersionResolverTests.__allTests),
    ]
}
#endif
