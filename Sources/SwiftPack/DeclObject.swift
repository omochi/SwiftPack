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
    init(tokens: [TokenSyntax]) {
        self.tokens = tokens
    }
    
    init(copy: DeclObject) {
        self.tokens = Array(SyntaxFactory.makeTokenList(copy.tokens))
    }
    
    var tokens: [TokenSyntax]
    
    func copy() -> DeclObject {
        return DeclObject(copy: self)
    }
    
    func debugReflect() -> DebugReflectValue {
        return .build { b in
            registerFields(builder: b)
        }
    }
    
    func registerFields(builder: DebugReflectBuilder) {}
    
    func write() -> String {
        return tokens.map { $0.description }.joined()
    }
}
