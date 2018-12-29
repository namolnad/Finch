// For more information about this configuration visit
// https://docs.fastlane.tools/actions/gym/#gymfile

// In general, you can use the options available
// fastlane gym --help

// Remove the // in front of the line to enable the option

class Gymfile: GymfileProtocol {
    var includeSymbols: Bool? { return false }
    var outputDirectory: String { return "./build" }
    var sdk: String { return "macos" }
    var scheme: String { return "\(appIdentifier)" }
}
