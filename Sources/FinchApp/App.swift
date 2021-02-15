import struct FinchCore.Configuration
import FinchUtilities
import Version

/// A structure to represent this app and its components.
public struct App {
    /// The meta information of the app.
    public struct Meta {
        /// The app's current build number.
        let buildNumber: Int

        /// The app's name.
        let name: String

        /// The app's current version.
        let version: Version

        /// :nodoc:
        public init(buildNumber: Int, name: String, version: Version) {
            self.buildNumber = buildNumber
            self.name = name
            self.version = version
        }
    }

    /// The app's derived configuration.
    let configuration: Configuration

    /// The app's current environment
    let environment: Environment

    /// The app's meta-information.
    let meta: Meta

    /// Output should be verbose
    let verbose: Bool

    /// The current print destination for the app,
    private let output: OutputType

    /// :nodoc:
    init(
        configuration: Configuration,
        environment: Environment = [:],
        meta: Meta,
        verbose: Bool = false,
        output: OutputType = Output.instance
    ) {
        self.configuration = configuration
        self.environment = environment
        self.meta = meta
        self.output = output
        self.verbose = verbose
    }

    /// Prints to the app's output.
    func print(_ value: String, kind: Output.Kind = .default) {
        output.print(value, kind: kind, verbose: verbose)
    }
}
