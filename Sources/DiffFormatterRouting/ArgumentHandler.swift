//
//  ArgumentHandler.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

extension ArgumentRouter {
    public typealias RouterArgumentHandling = ArgumentHandling<ArgumentScheme>

    public struct ArgumentHandling<Arguments> {
        let handle: (RoutingContext, Arguments) -> HandleResult

        public init(handle: @escaping (RoutingContext, Arguments) -> HandleResult) {
            self.handle = handle
        }
    }
}
