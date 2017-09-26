//
//  UnknownDecl.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/26.
//

import Foundation
import SwiftSyntax
import DebugReflect

final class UnknownDecl : DeclObjectProtocol,
LeadingTokensProtocol {    
    init(tokens: [TokenSyntax]) {
        self.leadingTokens = tokens
    }
    
    var leadingTokens: [TokenSyntax]
    
    func copy() -> UnknownDecl {
        return UnknownDecl(tokens: leadingTokens)
    }
    
    func debugReflect() -> DebugReflectValue {
        return .build { b in
            b.field("tokens", leadingTokens)
        }
    }
}
