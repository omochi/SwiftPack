//
//  UnknownDecl.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/26.
//

import Foundation
import SwiftSyntax
import DebugReflect

class UnknownDecl : DeclObject {
    init(tokens: [TokenSyntax]) {
        self.tokens = tokens
    }
    
    var tokens: [TokenSyntax]
    
    override func copy() -> DeclObject {
        return UnknownDecl(tokens: tokens)
    }
    
    override func registerFields(builder: DebugReflectBuilder) {
        builder.field("tokens", tokens)
    }
    
    override var leadingTrivia: Trivia {
        get {
            return tokens[0].leadingTrivia
        }
        set {
            tokens[0] = tokens[0].withLeadingTrivia(newValue)
        }
    }
    
    override func write() -> String {
        return tokens.map { String(describing: $0) }.joined()
    }
}
