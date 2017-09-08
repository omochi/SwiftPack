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
    override init() {
        super.init()
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
    
    static func parse(node: DeclSyntax) throws -> ImportDecl {
        let tokens = Array(SyntaxFactory.makeTokenList(node.children.map { $0 as! TokenSyntax }))
        let keywordIndex = try nonNil(findIndex(tokens){ $0.value.text == "import" }, "import keyword")
        let ret = ImportDecl()
        ret.tokens = tokens
        ret.keywordIndex = keywordIndex
        ret.nameIndex = keywordIndex + 1
        return ret
    }
}