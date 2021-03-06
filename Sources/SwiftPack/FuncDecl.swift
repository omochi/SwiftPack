//
//  FuncDecl.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/19.
//

import Foundation
import SwiftSyntax
import DebugReflect

final class FuncDecl : DeclObjectProtocol,
    LeadingTokensProtocol,
VisibilityDeclProtocol 
{
    init(visibilityIndex: Int?,
         keywordIndex: Int,
         nameIndex: Int,
         tokens: [TokenSyntax])
    {
        self.visibilityIndex = visibilityIndex
        self.keywordIndex = keywordIndex
        self.nameIndex = nameIndex
        self.leadingTokens = tokens
    }
    
    init(copy: FuncDecl) {
        self.keywordIndex = copy.keywordIndex
        self.nameIndex = copy.nameIndex
        self.leadingTokens = copy.leadingTokens
    }
    
    func copy() -> FuncDecl {
        return FuncDecl(copy: self)
    }
    
    var visibilityIndex: Int?
    var visibility: TokenSyntax? {
        return visibilityIndex.map { leadingTokens[$0] }
    }
    
    var keywordIndex: Int
    var keyword: TokenSyntax {
        return leadingTokens[keywordIndex]
    }
    
    var nameIndex: Int
    var name: TokenSyntax {
        return leadingTokens[nameIndex]
    }
    
    var leadingTokens: [TokenSyntax]
    
    func debugReflect() -> DebugReflectValue {
        return .build { b in
            b.fieldIfPresent("visibility", visibility?.text)
            b.field("keyword", keyword.text)
            b.field("name", name.text)
        }
    }
    
    func setVisibility(tokenKind: TokenKind?) {
        if let tokenKind = tokenKind {
            if let visibilityIndex = self.visibilityIndex {
                leadingTokens = updateToken(tokens: leadingTokens, kind: tokenKind, at: visibilityIndex)
            } else {
                leadingTokens = insertToken(tokens: leadingTokens, kind: tokenKind, at: keywordIndex)
                visibilityIndex = keywordIndex
                keywordIndex += 1
                nameIndex += 1
            }
        } else {
            if let visibilityIndex = self.visibilityIndex {
                leadingTokens = removeToken(tokens: leadingTokens, at: visibilityIndex)
                self.visibilityIndex = nil
                keywordIndex -= 1
                nameIndex -= 1
            }
        }
    }
}
