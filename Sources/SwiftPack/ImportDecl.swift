//
//  ImportDecl.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/08.
//

import Foundation
import DebugReflect
import SwiftSyntax

class ImportDecl : DeclObject {
    init(keywordIndex: Int,
         nameIndex: Int,
         tokens: [TokenSyntax])
    {
        self.keywordIndex = keywordIndex
        self.nameIndex = nameIndex
        super.init(tokens: tokens)
    }
    
    init(copy: ImportDecl) {
        keywordIndex = copy.keywordIndex
        nameIndex = copy.nameIndex
        super.init(copy: copy)
    }
    
    var keywordIndex: Int = 0
    var keyword: TokenSyntax {
        return tokens[keywordIndex]
    }
    
    var nameIndex: Int = 0
    var name: TokenSyntax {
        return tokens[nameIndex]
    }
    
    override func registerFields(builder b: DebugReflectBuilder) {
        super.registerFields(builder: b)
        b.field("name", name.text)
    }
    
    override func copy() -> DeclObject {
        return ImportDecl(copy: self)
    }
}
