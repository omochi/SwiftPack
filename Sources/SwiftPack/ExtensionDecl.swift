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
         rightBraceToken: TokenSyntax)
    {
        self.visibilityIndex = visibilityIndex
        self.keywordIndex = keywordIndex
        self.rightBraceToken = rightBraceToken
        super.init(tokens: tokens)
    }
    
    init(copy: ExtensionDecl) {
        self.visibilityIndex = copy.visibilityIndex
        self.keywordIndex = copy.keywordIndex
        self.rightBraceToken = copy.rightBraceToken
        super.init(copy: copy)
    }
    
    var visibilityIndex: Int?
    var visibility: TokenSyntax? {
        return visibilityIndex.map { tokens[$0] }
    }
    
    var keywordIndex: Int
    var keyword: TokenSyntax {
        return tokens[keywordIndex]
    }
    
    var rightBraceToken: TokenSyntax
    
    override func copy() -> DeclObject {
        return ExtensionDecl(copy: self)
    }
    
    override func write() -> String {
        return tokens.map { $0.description }.joined() +
        rightBraceToken.description
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
}