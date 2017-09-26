//
//  TypeAliasDecl.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/19.
//

import Foundation
import SwiftSyntax
import DebugReflect

class TypeAliasDecl : DeclObject, VisibilityControllable {
    init(visibilityIndex: Int?,
         keywordIndex: Int,
         tokens: [TokenSyntax])
    {
        self.visibilityIndex = visibilityIndex
        self.keywordIndex = keywordIndex
        self.tokens = tokens
    }
    
    init(copy: TypeAliasDecl) {
        visibilityIndex = copy.visibilityIndex
        keywordIndex = copy.keywordIndex
        tokens = copy.tokens
    }
    
    override func copy() -> DeclObject {
        return TypeAliasDecl(copy: self)
    }
    
    var visibilityIndex: Int?
    var visibility: TokenSyntax? {
        return visibilityIndex.map { tokens[$0] }
    }
    
    var keywordIndex: Int = 0
    var keyword: TokenSyntax {
        return tokens[keywordIndex]
    }
    
    var tokens: [TokenSyntax]
    
    func setVisibility(tokenKind: TokenKind?) {
        if let tokenKind = tokenKind {
            if let visibilityIndex = self.visibilityIndex {
                tokens = updateToken(tokens: tokens, kind: tokenKind, at: visibilityIndex)
            } else {
                tokens = insertToken(tokens: tokens, kind: tokenKind, at: keywordIndex)
                visibilityIndex = keywordIndex
                keywordIndex += 1
            }
        } else {
            if let visibilityIndex = self.visibilityIndex {
                tokens = removeToken(tokens: tokens, at: visibilityIndex)
                self.visibilityIndex = nil
                keywordIndex -= 1
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
