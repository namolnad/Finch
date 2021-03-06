import FinchCore
import FinchUtilities
import Foundation

/// A structure tasked with creating and returning the app's configuration.
struct Configurator {
    /// The app's configuration.
    var configuration: Configuration {
        getConfiguration()
    }

    /**
     * Paths for which the configurator should continue
     * to modify the existing config with the next found config.
     */
    private let cascadingPaths: [String]

    private let cascadingResolver: FileResolver<Configuration>

    private let cascadingPrivateResolver: FileResolver<Configuration>

    private let defaultConfig: Configuration

    /**
     * Paths for which the configurator should return
     * the first valid configuration.
     */
    private let immediateResolver: FileResolver<Configuration>

    private let immediateReturnPaths: [String]

    private let output: OutputType

    /// :nodoc:
    init(
        configPath: String?,
        projectDir: String?,
        meta: App.Meta,
        environment: Environment,
        fileManager: FileManager = .default,
        output: OutputType = Output.instance
    ) {
        self.cascadingResolver = .init(
            fileManager: fileManager,
            pathComponent: "/.\(meta.name.lowercased())/config.yml"
        )

        self.cascadingPrivateResolver = .init(
            fileManager: fileManager,
            pathComponent: "/.\(meta.name.lowercased())/config.private.yml"
        )

        // The immediate resolver expects an exact path to be passed in through the environment variable
        self.immediateResolver = .init(fileManager: fileManager)

        let immediateReturnPaths = [
            configPath,
            environment["\(meta.name.uppercased())_CONFIG"]
        ]

        self.immediateReturnPaths = immediateReturnPaths
            .compactMap { $0 }
            .filter { !$0.isEmpty }

        self.defaultConfig = .default(projectDir: projectDir ?? fileManager.currentDirectoryPath)

        self.output = output

        let homeDirectoryPath: String
        if #available(OSX 10.12, *) {
            homeDirectoryPath = fileManager.homeDirectoryForCurrentUser.path
        } else {
            homeDirectoryPath = NSHomeDirectory()
        }

        var cascadingPaths = [
            homeDirectoryPath,
            fileManager.currentDirectoryPath
        ]

        // Append project dir if passed in as argument
        if let value = projectDir {
            cascadingPaths.append(value)
        }

        self.cascadingPaths = cascadingPaths.filter { !$0.isEmpty }
    }

    private func getConfiguration() -> Configuration {
        // Start with default configuration
        var configuration = defaultConfig

        do {
            if let config = try immediateReturnPaths.firstMap(immediateResolver.resolve) {
                config.merge(into: &configuration)
                return configuration
            }

            for path in cascadingPaths {
                if let config = try cascadingResolver.resolve(path: path) {
                    config.merge(into: &configuration)
                }

                if let config = try cascadingPrivateResolver.resolve(path: path) {
                    config.merge(into: &configuration)
                }
            }
        } catch {
            output.print("\(error)", kind: .error, verbose: false)
        }

        return configuration
    }
}
