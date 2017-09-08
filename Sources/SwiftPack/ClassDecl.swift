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
    override init() {
        super.init()
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
        b.fieldIfPresent("visibility", visibility?.text)
        b.field("keyword", keyword.text)
        b.field("name", name.text)
    }
    
    override func copy() -> DeclObject {
        return ClassDecl(copy: self)
    }
    
    func setVisibility(tokenKind: TokenKind?) {
        if var visibilityToken = self.visibility {
            if let tokenKind = tokenKind {
                // replace token
                visibilityToken = visibilityToken.withKind(tokenKind)
                tokens[visibilityIndex!] = visibilityToken
            } else {
                // remove token
                let rightIndex = visibilityIndex! + 1
                var rightToken = tokens[rightIndex]
                rightToken = rightToken
                    .withLeadingTrivia(visibilityToken.leadingTrivia +
                        visibilityToken.trailingTrivia +
                        rightToken.leadingTrivia)
                tokens[rightIndex] = rightToken
                visibilityIndex = nil
                keywordIndex -= 1
                nameIndex -= 1
            }
        } else {
            if let tokenKind = tokenKind {
                var keyword = self.keyword
                
                // insert token
                let token = SyntaxFactory.makeToken(tokenKind, presence: .present,
                                                    leadingTrivia: keyword.leadingTrivia,
                                                    trailingTrivia: .spaces(1))
                tokens.insert(token, at: keywordIndex)
                visibilityIndex = keywordIndex
                keywordIndex += 1
                nameIndex += 1
                
                keyword = keyword.withoutLeadingTrivia()
                tokens[keywordIndex] = keyword
            }
        }
    }
    
    static func parse(node: DeclSyntax) throws -> ClassDecl {
        let tokens = Array(SyntaxFactory.makeTokenList(node.children.map { $0 as! TokenSyntax }))
        let keywordIndex = try nonNil(findIndex(tokens){ classKeywords.contains($0.value.text) }, "class keyword")
        let ret = ClassDecl()
        ret.tokens = tokens
        ret.keywordIndex = keywordIndex
        ret.nameIndex = keywordIndex + 1
        let visibilityIndex = findIndex(tokens, range: 0..<keywordIndex) { visibilityKeywords.contains($0.value.text) }
        ret.visibilityIndex = visibilityIndex
        return ret
    }
}
