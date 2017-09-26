//
//  ImportDecl.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/08.
//

import Foundation
import DebugReflect
import SwiftSyntax

final class ImportDecl : DeclObjectProtocol,
    LeadingTokensProtocol
{
    init(keywordIndex: Int,
         nameIndex: Int,
         tokens: [TokenSyntax])
    {
        self.keywordIndex = keywordIndex
        self.nameIndex = nameIndex
        self.leadingTokens = tokens
    }
    
    init(copy: ImportDecl) {
        keywordIndex = copy.keywordIndex
        nameIndex = copy.nameIndex
        leadingTokens = copy.leadingTokens
    }
    
    var keywordIndex: Int = 0
    var keyword: TokenSyntax {
        return leadingTokens[keywordIndex]
    }
    
    var nameIndex: Int = 0
    var name: TokenSyntax {
        return leadingTokens[nameIndex]
    }
    
    var leadingTokens: [TokenSyntax]
    
    func copy() -> ImportDecl {
        return ImportDecl(copy: self)
    }
    
    func debugReflect() -> DebugReflectValue {
        return .build { b in
            b.field("keyword", keyword.text)
            b.field("name", name.text)
            b.field("leadingTokens", leadingTokens)
        }
    }
}
