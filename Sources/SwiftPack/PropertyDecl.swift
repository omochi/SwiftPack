//
//  PropertyDecl.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/26.
//

import Foundation
import SwiftSyntax
import DebugReflect

class PropertyDecl : DeclObject {
    init(visibilityIndex: Int?,
         keywordIndex: Int,
         tokens: [TokenSyntax])
    {
        self.visibilityIndex = visibilityIndex
        self.keywordIndex = keywordIndex
        self.tokens = tokens
    }
    
    init(copy: PropertyDecl) {
        self.visibilityIndex = copy.visibilityIndex
        self.keywordIndex = copy.keywordIndex
        self.tokens = copy.tokens
    }
    
    override func copy() -> DeclObject {
        return PropertyDecl(copy: self)
    }
    
    var visibilityIndex: Int?
    var visibility: TokenSyntax? {
        return visibilityIndex.map { tokens[$0] }
    }
    
    var keywordIndex: Int
    var keyword: TokenSyntax {
        return tokens[keywordIndex]
    }
    
    var tokens: [TokenSyntax]
    
    override func registerFields(builder: DebugReflectBuilder) {
        builder.field("tokens", tokens)
        super.registerFields(builder: builder)
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
        return tokens.map { $0.description }.joined()
    }
}
