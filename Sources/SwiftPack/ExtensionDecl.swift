//
//  ExtensionDecl.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/22.
//

import Foundation
import DebugReflect
import SwiftSyntax

class ExtensionDecl : DeclObject, VisibilityControllable {
    init(visibilityIndex: Int?,
         keywordIndex: Int,
         tokens: [TokenSyntax],
         isConformance: Bool,
         decls: [DeclObject],
         rightBraceToken: TokenSyntax)
    {
        self.visibilityIndex = visibilityIndex
        self.keywordIndex = keywordIndex
        self.tokens = tokens
        self.isConformance = isConformance
        self.decls = decls
        self.rightBraceToken = rightBraceToken
    }
    
    init(copy: ExtensionDecl) {
        self.visibilityIndex = copy.visibilityIndex
        self.keywordIndex = copy.keywordIndex
        self.tokens = copy.tokens
        self.isConformance = copy.isConformance
        self.decls = copy.decls.map { $0.copy() }
        self.rightBraceToken = copy.rightBraceToken
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
    
    var isConformance: Bool
    
    var decls: [DeclObject]
    
    var rightBraceToken: TokenSyntax
    
    override func copy() -> DeclObject {
        return ExtensionDecl(copy: self)
    }
    
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
        return tokens.map { $0.description }.joined() +
            decls.map { $0.write() }.joined() +
            rightBraceToken.description
    }
}
