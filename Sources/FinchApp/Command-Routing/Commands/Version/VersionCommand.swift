import Commandant
import Curry
import FinchUtilities

final class VersionCommand: Command {
    final class VersionOptions: App.Options, OptionsProtocol {

        typealias ClientError = AppError

        static func evaluate(_ m: CommandMode) -> Result<VersionCommand.VersionOptions, CommandantError<ClientError>> {
            return curry(self.init)
                <*> m <| Option<String?>(key: App.Options.Key.configPath.rawValue, defaultValue: nil, usage: Strings.App.Options.configPath)
                <*> m <| Option<String?>(key: App.Options.Key.projectDir.rawValue, defaultValue: nil, usage: Strings.App.Options.projectDir)
                <*> m <| Switch(key: App.Options.Key.verbose.rawValue, usage: Strings.App.Options.verbose)
        }
    }

    typealias ClientError = AppError

    typealias Options = VersionOptions

    let environment: Environment

    let function: String = Strings.App.Options.showVersion

    let meta: App.Meta

    let output: OutputType

    let verb: String = "version"

    init(env: Environment, meta: App.Meta, output: OutputType) {
        self.environment = env
        self.meta = meta
        self.output = output
    }

    func run(options: Options, app: App, env: Environment) -> Result<(), ClientError> {
        app.print("\(app.meta.name) \(app.meta.version) (\(app.meta.buildNumber))")
        return .success(())
    }
}
