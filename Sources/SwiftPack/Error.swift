//
//  Error.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/08.
//

import Foundation

struct Error : Swift.Error, CustomStringConvertible {
    init(_ message: String) {
        self.message = message
    }
    
    var message: String
    
    var description: String {
        return "Error(\(message))"
    }
}
