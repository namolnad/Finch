// For more information about this configuration visit
// https://docs.fastlane.tools/actions/scan/#scanfile

// In general, you can use the options available
// fastlane scan --help

private var identifier: String { return appIdentifier }

class Scanfile: ScanfileProtocol {
    var clean: Bool { return true }
    var codeCoverage: Bool? { return true }
    var openReport: Bool { return true }
    var project: String? { return "\(identifier).xcodeproj" }
    var scheme: String? { return identifier }
    var sdk: String? { return "macosx" }
    var skipSlack: Bool { return true }
}
