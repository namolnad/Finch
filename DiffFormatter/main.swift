//
//  main.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

let router = ArgumentRouter()

router.route(arguments: ProcessInfo().arguments)
