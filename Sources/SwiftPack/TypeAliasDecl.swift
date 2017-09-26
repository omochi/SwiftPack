//
//  TypeAliasDecl.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/19.
//

import Foundation
import SwiftSyntax
import DebugReflect

final class TypeAliasDecl : DeclObjectProtocol,
    LeadingTokensProtocol,
    VisibilityDeclProtocol
{
    init(visibilityIndex: Int?,
         keywordIndex: Int,
         tokens: [TokenSyntax])
    {
        self.visibilityIndex = visibilityIndex
        self.keywordIndex = keywordIndex
        self.leadingTokens = tokens
    }
    
    init(copy: TypeAliasDecl) {
        visibilityIndex = copy.visibilityIndex
        keywordIndex = copy.keywordIndex
        leadingTokens = copy.leadingTokens
    }
    
    func copy() -> TypeAliasDecl {
        return TypeAliasDecl(copy: self)
    }
    
    var visibilityIndex: Int?
    var visibility: TokenSyntax? {
        return visibilityIndex.map { leadingTokens[$0] }
    }
    
    var keywordIndex: Int = 0
    var keyword: TokenSyntax {
        return leadingTokens[keywordIndex]
    }
    
    var leadingTokens: [TokenSyntax]

    func debugReflect() -> DebugReflectValue {
        return .build { b in
            b.field("keyword", keyword.text)
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
            }
        } else {
            if let visibilityIndex = self.visibilityIndex {
                leadingTokens = removeToken(tokens: leadingTokens, at: visibilityIndex)
                self.visibilityIndex = nil
                keywordIndex -= 1
            }
        }
    }
}
