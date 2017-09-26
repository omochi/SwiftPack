//
//  ExtensionDecl.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/22.
//

import Foundation
import DebugReflect
import SwiftSyntax

final class ExtensionDecl : DeclObjectProtocol,
LeadingTokensProtocol,
VisibilityDeclProtocol{
    init(visibilityIndex: Int?,
         keywordIndex: Int,
         leadingTokens: [TokenSyntax],
         isConformance: Bool,
         decls: [AnyDeclObject],
         rightBraceToken: TokenSyntax)
    {
        self.visibilityIndex = visibilityIndex
        self.keywordIndex = keywordIndex
        self.leadingTokens = leadingTokens
        self.isConformance = isConformance
        self.decls = decls
        self.rightBraceToken = rightBraceToken
    }
    
    init(copy: ExtensionDecl) {
        self.visibilityIndex = copy.visibilityIndex
        self.keywordIndex = copy.keywordIndex
        self.leadingTokens = copy.leadingTokens
        self.isConformance = copy.isConformance
        self.decls = copy.decls.map { $0.copy() }
        self.rightBraceToken = copy.rightBraceToken
    }
    
    var visibilityIndex: Int?
    var visibility: TokenSyntax? {
        return visibilityIndex.map { leadingTokens[$0] }
    }
    
    var keywordIndex: Int
    var keyword: TokenSyntax {
        return leadingTokens[keywordIndex]
    }
    
    var leadingTokens: [TokenSyntax]
    
    var isConformance: Bool
    
    var decls: [AnyDeclObject]
    
    var rightBraceToken: TokenSyntax
    
    func copy() -> ExtensionDecl {
        return ExtensionDecl(copy: self)
    }
    
    func debugReflect() -> DebugReflectValue {
        return .build { b in
            b.fieldIfPresent("visibility", visibility?.text)
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

    func write() -> String {
        return leadingTokens.map { $0.description }.joined() +
            decls.map { $0.write() }.joined() +
            rightBraceToken.description
    }
}
