//
//  DeclObject.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/08.
//

import Foundation
import DebugReflect
import SwiftSyntax

class DeclObject : DebugReflectable {    
    func copy() -> DeclObject {        
        fatalError("must override")
    }
    
    func debugReflect() -> DebugReflectValue {
        return .build { b in
            registerFields(builder: b)
        }
    }
    
    func registerFields(builder: DebugReflectBuilder) {}
    
    var leadingTrivia: Trivia {
        get {
            fatalError("must override")
        }
        set {
            fatalError("must override")
        }
    }
    
    func write() -> String {
        fatalError("must override")
    }
}
