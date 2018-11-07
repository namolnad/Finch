//
//  VersionHandler.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

extension ArgumentRouter {
    private static let versionArguments: [Argument] = [.flag(.version), .flag(.versionAbbreviated)]

    static let versionHandler: RouterArgumentHandling = .init { context, scheme in
        guard scheme.args.contains(where: versionArguments.contains) else {
            return .notHandled
        }

        print("\(context.app.name) \(context.app.version) (\(context.app.buildNumber))")

        return .handled
    }
}
