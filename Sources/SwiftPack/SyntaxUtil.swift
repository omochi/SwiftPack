//
//  SyntaxUtil.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/19.
//

import Foundation
import SwiftSyntax

func insertToken(tokens: [TokenSyntax], kind: TokenKind, at: Int) -> [TokenSyntax] {
    var tokens = tokens
    
    let rightIndex = at
    let rightToken = tokens.getOrNil(at: rightIndex)

    let newToken = SyntaxFactory.makeToken(kind, presence: .present,
                                           leadingTrivia: rightToken?.leadingTrivia ?? .zero,
                                           trailingTrivia: rightToken != nil ? .spaces(1) : .zero)
    
    if var newRightToken = rightToken {
        newRightToken = newRightToken.withoutLeadingTrivia()
        tokens[rightIndex] = newRightToken
    }
    
    tokens.insert(newToken, at: at)
    
    return tokens
}

func removeToken(tokens: [TokenSyntax], at: Int) -> [TokenSyntax] {
    var tokens = tokens
    
    let removingToken = tokens[at]
    
    let rightIndex = at + 1
    
    if var rightToken = tokens.getOrNil(at: rightIndex) {
        rightToken = rightToken
            .withLeadingTrivia(removingToken.leadingTrivia +
                rightToken.leadingTrivia)
        tokens[rightIndex] = rightToken
    }
    
    tokens.remove(at: at)

    return tokens
}

func updateToken(tokens: [TokenSyntax], kind: TokenKind, at: Int) -> [TokenSyntax] {
    var tokens = tokens
    tokens[at] = tokens[at].withKind(kind)
    return tokens
}



