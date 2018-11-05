//
//  VersionHandler.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

extension ArgumentRouter {
    private static let versionArguments: [String] = ["--version, -v"]

    static let versionHandler: RouterArgumentHandling = .init { context, args in
        guard args.contains(where: versionArguments.contains) else {
            return .notHandled
        }

        print("\(context.app.name) \(context.app.version) (\(context.app.buildNumber))")

        return .handled
    }
}
