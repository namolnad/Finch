import FinchApp
import Foundation

let meta: App.Meta = .init(
    buildNumber: appBuildNumber,
    name: appName,
    version: appVersion
)

let result = AppRunner(
    environment: ProcessInfo.processInfo.environment,
    meta: meta
).run(with: CommandLine.arguments)

exit(result)
