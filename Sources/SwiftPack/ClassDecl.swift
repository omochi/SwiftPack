//
//  StructCode.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/08.
//

import Foundation
import DebugReflect
import SwiftSyntax

class ClassDecl : DeclObject {
    init(visibilityIndex: Int?,
         keywordIndex: Int,
         nameIndex: Int,
         tokens: [TokenSyntax])
    {
        self.visibilityIndex = visibilityIndex
        self.keywordIndex = keywordIndex
        self.nameIndex = nameIndex
        super.init(tokens: tokens)
    }
    
    init(copy: ClassDecl) {
        visibilityIndex = copy.visibilityIndex
        keywordIndex = copy.keywordIndex
        nameIndex = copy.nameIndex
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
    
    var nameIndex: Int
    var name: TokenSyntax {
        return tokens[nameIndex]
    }
    
    override func registerFields(builder b: DebugReflectBuilder) {
        super.registerFields(builder: b)
        b.fieldIfPresent("visibility", visibility?.text)
        b.field("keyword", keyword.text)
        b.field("name", name.text)
    }
    
    override func copy() -> DeclObject {
        return ClassDecl(copy: self)
    }
    
    func setVisibility(tokenKind: TokenKind?) {
        if let tokenKind = tokenKind {
            if let visibilityIndex = self.visibilityIndex {
                tokens = updateToken(tokens: tokens, kind: tokenKind, at: visibilityIndex)
            } else {
                tokens = insertToken(tokens: tokens, kind: tokenKind, at: keywordIndex)
                visibilityIndex = keywordIndex
                keywordIndex += 1
                nameIndex += 1
            }
        } else {
            if let visibilityIndex = self.visibilityIndex {
                tokens = removeToken(tokens: tokens, at: visibilityIndex)
                self.visibilityIndex = nil
                keywordIndex -= 1
                nameIndex -= 1
            }
        }
    }
    
    static func parse(node: DeclSyntax) throws -> ClassDecl {
        let tokens = Array(SyntaxFactory.makeTokenList(node.children.map { $0 as! TokenSyntax }))
        let keywordIndex = try nonNil(findIndex(tokens){ classKeywords.contains($0.value.text) }, "class keyword")
        let visibilityIndex = findIndex(tokens, range: 0..<keywordIndex) {
            visibilityKeywords.contains($0.value.text) }
        return ClassDecl(visibilityIndex: visibilityIndex,
                         keywordIndex : keywordIndex,
                         nameIndex: keywordIndex + 1,
                         tokens: tokens)
    }
}
