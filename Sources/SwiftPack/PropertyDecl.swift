//
//  PropertyDecl.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/26.
//

import Foundation
import SwiftSyntax
import DebugReflect

final class PropertyDecl : DeclObjectProtocol,
    VisibilityDeclProtocol,
LeadingTokensProtocol {
    init(visibilityIndex: Int?,
         keywordIndex: Int,
         tokens: [TokenSyntax])
    {
        self.visibilityIndex = visibilityIndex
        self.keywordIndex = keywordIndex
        self.leadingTokens = tokens
    }
    
    init(copy: PropertyDecl) {
        self.visibilityIndex = copy.visibilityIndex
        self.keywordIndex = copy.keywordIndex
        self.leadingTokens = copy.leadingTokens
    }
    
    func copy() -> PropertyDecl {
        return PropertyDecl(copy: self)
    }
    
    var visibilityIndex: Int?
    var visibility: TokenSyntax? {
        return visibilityIndex.map { leadingTokens[$0] }
    }
    
    var keywordIndex: Int
    var keyword: TokenSyntax {
        return leadingTokens[keywordIndex]
    }
    
    func debugReflect() -> DebugReflectValue {
        return .build { b in
//            b.fieldIfPresent("visibility", visibility?.text)
//            b.field("keyword", keyword.text)
            b.fieldIfPresent("visi", visibilityIndex)
            b.field("keyword", keywordIndex)
            b.field("tokens", leadingTokens)
        }
    }
    
    var leadingTokens: [TokenSyntax]
    
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
