//
//  DiffHandler.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

extension ArgumentRouter {
    static let diffHandler: RouterArgumentHandling = .init { context, scheme in
        guard let oldVersion = scheme.oldVersion, let newVersion = scheme.newVersion else {
            return .notHandled
        }

        let versionHeader: String? = scheme.args.contains(.flag(.noShowVersion)) ? nil : scheme.newVersion

        var releaseManager: Contributor?
        for case let .actionable(.releaseManager, email) in scheme.args {
            releaseManager = context.configuration.contributors.first { $0.email == email }
            break
        }

        var projectDir: String = context.configuration.currentDirectory
        for case let .actionable(.projectDir, dir) in scheme.args {
            projectDir = dir
            break
        }

        var manualDiff: String?
        for case let .actionable(.gitDiff, diff) in scheme.args {
            manualDiff = diff
            break
        }

        let rawDiff = manualDiff ??
            Utilities.GitDiffer(configuration: context.configuration,
                      projectDir: projectDir,
                      oldVersion: oldVersion,
                      newVersion: newVersion).diff

        let outputGenerator: Utilities.OutputGenerator = .init(
            configuration: context.configuration,
            rawDiff: rawDiff,
            version: versionHeader,
            releaseManager: releaseManager
        )

        output(generator: outputGenerator)

        return .handled
    }

    private static func output(generator: Utilities.OutputGenerator) {
        guard !Utilities.isTest else {
            return
        }

        let result = generator.generatedOutput()

        Utilities.pbCopy(text: result)

        print("Output copied to pasteboard: \(result)")
    }
}
