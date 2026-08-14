import ArgumentParser
import FinchUtilities
import Foundation

/**
 * A class responsible for running the app. Parses the arguments, builds the
 * `App` the selected command runs against, and reports the exit code.
 */
public class AppRunner {
    private let environment: Environment
    private let meta: App.Meta
    private let output: OutputType

    /// :nodoc:
    public init(environment: Environment, meta: App.Meta, output: OutputType = Output.instance) {
        self.environment = environment
        self.meta = meta
        self.output = output
    }

    /// Runs the app
    @discardableResult
    public func run(with arguments: [String]) -> Int32 {
        let arguments = Array(arguments.dropFirst())

        // The version is generated into the binary at build time, so it is
        // known here rather than to the statically-configured parser
        if arguments.first == Strings.App.Options.versionFlag {
            output.print(meta.versionDescription, kind: .default, verbose: false)
            return 0
        }

        do {
            var command = try FinchCommand.parseAsRoot(arguments)

            if let command = command as? AppCommand {
                try command.run(with: app(for: command.globalOptions))
            } else {
                try command.run()
            }

            return 0
        } catch {
            let exitCode = FinchCommand.exitCode(for: error)

            output.print(
                FinchCommand.fullMessage(for: error),
                kind: exitCode == .success ? .default : .error,
                verbose: false
            )

            return exitCode.rawValue
        }
    }

    private func app(for globalOptions: GlobalOptions) -> App {
        let configuration = Configurator(
            configPath: globalOptions.config,
            projectDir: globalOptions.projectDir,
            meta: meta,
            environment: environment,
            output: output
        ).configuration

        return .init(
            configuration: configuration.applying(commitStyle: globalOptions.commitStyle),
            environment: environment,
            meta: meta,
            verbose: globalOptions.verbose,
            output: output
        )
    }
}
