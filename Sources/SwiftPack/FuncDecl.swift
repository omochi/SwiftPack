//
//  FuncDecl.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/19.
//

import Foundation
import SwiftSyntax
import DebugReflect

class FuncDecl : DeclObject, VisibilityControllable {
    init(visibilityIndex: Int?,
         keywordIndex: Int,
         nameIndex: Int,
         tokens: [TokenSyntax])
    {
        self.visibilityIndex = visibilityIndex
        self.keywordIndex = keywordIndex
        self.nameIndex = nameIndex
        self.tokens = tokens
    }
    
    init(copy: FuncDecl) {
        self.keywordIndex = copy.keywordIndex
        self.nameIndex = copy.nameIndex
        self.tokens = copy.tokens
    }
    
    override func copy() -> DeclObject {
        return FuncDecl(copy: self)
    }
    
    var visibilityIndex: Int?
    var visibility: TokenSyntax? {
        return visibilityIndex.map { tokens[$0] }
    }
    
    var keywordIndex: Int
    var keyword: TokenSyntax {
        return tokens[keywordIndex]
    }
    
    var nameIndex: Int
    var name: TokenSyntax {
        return tokens[nameIndex]
    }
    
    var tokens: [TokenSyntax]
    
    override func registerFields(builder b: DebugReflectBuilder) {
        super.registerFields(builder: b)
        b.fieldIfPresent("visibility", visibility?.text)
        b.field("keyword", keyword.text)
        b.field("name", name.text)
    }
    
    func setVisibility(tokenKind: TokenKind?) {
        if let tokenKind = tokenKind {
            if let visibilityIndex = self.visibilityIndex {
                tokens = updateToken(tokens: tokens, kind: tokenKind, at: visibilityIndex)
            } else {
                tokens = insertToken(tokens: tokens, kind: tokenKind, at: keywordIndex)
                visibilityIndex = keywordIndex
                keywordIndex += 1
                nameIndex += 1
            }
        } else {
            if let visibilityIndex = self.visibilityIndex {
                tokens = removeToken(tokens: tokens, at: visibilityIndex)
                self.visibilityIndex = nil
                keywordIndex -= 1
                nameIndex -= 1
            }
        }
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
