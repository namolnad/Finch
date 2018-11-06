//
//  ArgumentRouter.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct ArgumentRouter {
    private let configuration: Configuration
    private let app: App

    private let handlers: [RouterArgumentHandling] = [
        ArgumentRouter.usageHandler,
        ArgumentRouter.versionHandler,
        ArgumentRouter.diffHandler
    ]

    init(app: App, configuration: Configuration) {
        self.app = app
        self.configuration = configuration
    }
}

extension ArgumentRouter {
    private var routingContext: Context {
        return .init(app: app, configuration: configuration)
    }

    func route(arguments: [String]) -> HandleResult {
        let args: [String] = arguments.reversed()

        for handler in handlers {
            switch handler.handle(routingContext, args) {
            case .handled:
                return .handled
            case .notHandled:
                continue
            case .partiallyHandled(unprocessedArgs: let unprocessedArgs):
                return route(arguments: unprocessedArgs.reversed())
            }
        }

        return .notHandled
    }
}
