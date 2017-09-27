//
//  SyntaxParser.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/22.
//

import Foundation
import SwiftSyntax

class SyntaxParser {
    func parse(source: SourceFileSyntax) throws -> SourceFile {
        let ret = SourceFile()
        for decl in source.topLevelDecls {
            let decl = try parseTopDecl(decl)
            ret.decls.append(decl)
        }
        ret.eofToken = source.eofToken
        return ret
    }
    
    func parseTopDecl(_ decl: DeclSyntax) throws -> AnyDeclObject {
        let tokens = Array(decl.children.map { $0 as! TokenSyntax })

        let ret = try parseDecls(tokens: tokens, startIndex: 0)
        precondition(ret.decls.count == 1)
        
        guard ret.endIndex == tokens.count else {
            throw Error("parse top decl error: rest index=\(ret.endIndex)..<\(tokens.endIndex)")
        }
        return ret.decls[0]
    }
    
    func parseDecls(tokens: Array<TokenSyntax>, startIndex: Int) throws -> (decls: [AnyDeclObject], endIndex: Int) {
        var index = startIndex
        var decls = [AnyDeclObject]()
        
        func appendDecl<X: DeclObjectProtocol>(_ x: (decl: X, endIndex: Int)) {
            decls.append(AnyDeclObject(x.decl))
            index = x.endIndex
        }
        
        while true {
            if index >= tokens.endIndex {
                break
            }
            let token = tokens[index]
            
            if let ret = try parseClassDecl(tokens: tokens, startIndex: index) {
                appendDecl(ret)
            } else if let ret = try parseImportDecl(tokens: tokens, startIndex: index) {
                appendDecl(ret)
            } else if let ret = try parseFuncDecl(tokens: tokens, startIndex: index) {
                appendDecl(ret)
            } else if let ret = try parseTypeAliasDecl(tokens: tokens, startIndex: index) {
                appendDecl(ret)
            } else if let ret = try parseExtensionDecl(tokens: tokens, startIndex: index) {
                appendDecl(ret)
            } else if let ret = try parsePropertyDecl(tokens: tokens, startIndex: index) {
                appendDecl(ret)
            } else if token.text == "}" {
                break
            } else {
                let ret = parseUnknownDecl(tokens: tokens, startIndex: index)
                appendDecl(ret)
                
                let unknownTokens = ret.decl.leadingTokens
                print("===unknown decl===")
                for i in 0..<unknownTokens.count {
                    print("  \(type(of: unknownTokens[i])): [\(unknownTokens[i])]")
                }
                print("===")
            }
        }
        
        return (decls: decls, endIndex: index)
    }
    
    func parseClassDecl(tokens: Array<TokenSyntax>, startIndex: Int) throws -> (decl: ClassDecl, endIndex: Int)? {
        var index = startIndex
        
        var visibilityIndex: Int?
        while true {
            if index >= tokens.endIndex {
                return nil
            }
            let token = tokens[index]
            
            if token.text == "@" {
                index += 2
            } else if visibilityKeywords.contains(token.text) {
                visibilityIndex = index
                index += 1
            } else if classKeywords.contains(token.text) {
                break
            } else {
                return nil
            }
        }
        
        let keywordIndex: Int = index
        index += 1
        let nameIndex: Int = index
        index += 1
        
        while true {
            if index >= tokens.endIndex {
                throw Error("no class body")
            }
            let token = tokens[index]
            
            if token.text == "{" {
                let ret = parseBraceBlock(tokens: tokens, startIndex: index)
                index = ret
                break
            } else {
                index += 1
            }
        }
        
        return (decl: ClassDecl(visibilityIndex: visibilityIndex.map { $0 - startIndex },
                                keywordIndex: keywordIndex - startIndex,
                                nameIndex: nameIndex - startIndex,
                                tokens: Array(tokens[startIndex..<index])),
                endIndex: index)
    }
    
    func parseImportDecl(tokens: Array<TokenSyntax>, startIndex: Int) throws -> (decl: ImportDecl, endIndex: Int)? {
        var index = startIndex
        
        while true {
            if index >= tokens.endIndex {
                return nil
            }
            let token = tokens[index]
            if token.text == "@" {
                index += 2
            } else if token.text == "import" {
                break
            } else {
                return nil
            }
        }
        
        let keywordIndex: Int = index
        index += 1
        let nameIndex: Int = index
        index += 1

        return (decl: ImportDecl(keywordIndex: keywordIndex - startIndex,
                                 nameIndex: nameIndex - startIndex,
                                 tokens: Array(tokens[startIndex..<index])),
                endIndex: index)
    }
    
    func parseFuncDecl(tokens: Array<TokenSyntax>, startIndex: Int) throws -> (decl: FuncDecl, endIndex: Int)? {
        var index = startIndex

        var visibilityIndex: Int?
        while true {
            if index >= tokens.endIndex {
                return nil
            }
            let token = tokens[index]
            
            if token.text == "@" {
                index += 2
            } else if visibilityKeywords.contains(token.text) {
                visibilityIndex = index
                index += 1
            } else if token.text == "func" {
                break
            } else {
                return nil
            }
        }
        
        let keywordIndex: Int = index
        index += 1
        let nameIndex: Int = index
        index += 1

        while true {
            if index >= tokens.endIndex {
                throw Error("no func body")
            }
            let token = tokens[index]
            if token.text == "{" {
                let ret = parseBraceBlock(tokens: tokens, startIndex: index)
                index = ret
                break
            } else {
                index += 1
            }
        }
        
        return (decl: FuncDecl(visibilityIndex: visibilityIndex.map { $0 - startIndex },
                               keywordIndex : keywordIndex - startIndex,
                               nameIndex: nameIndex - startIndex,
                               tokens: Array(tokens[startIndex..<index])),
                endIndex: index)
    }
    
    func parseTypeAliasDecl(tokens: Array<TokenSyntax>, startIndex: Int) throws -> (decl: TypeAliasDecl, endIndex: Int)? {
        var index = startIndex
        var visibilityIndex: Int?
        while true {
            if index >= tokens.endIndex {
                return nil
            }
            let token = tokens[index]
            if visibilityKeywords.contains(token.text) {
                visibilityIndex = index
                index += 1
            } else if token.text == "typealias" {
                break
            } else {
                return nil
            }
        }
        
        let keywordIndex: Int = index
        index += 4
        
        return (decl: TypeAliasDecl(visibilityIndex: visibilityIndex.map { $0 - startIndex },
                                    keywordIndex : keywordIndex - startIndex,
                                    tokens: Array(tokens[startIndex..<index])),
                endIndex: index)
    }
    
    func parseExtensionDecl(tokens: Array<TokenSyntax>, startIndex: Int) throws -> (decl: ExtensionDecl, endIndex: Int)? {
        var index = startIndex
        var visibilityIndex: Int?
        while true {
            if index >= tokens.endIndex {
                return nil
            }
            let token = tokens[index]
            if visibilityKeywords.contains(token.text) {
                visibilityIndex = index
                index += 1
            } else if token.text == "extension" {
                break
            } else {
                return nil
            }
        }
        
        let keywordIndex: Int = index
        index += 1
        
        // name
        index += 1
        
        var isConformance: Bool = false
        
        while true {
            if index >= tokens.endIndex {
                break
            }
            let token = tokens[index]
            if token.text == "{" {
                break
            } else if token.text == ":" {
                isConformance = true
                index += 1
                break
            } else {
                break
            }
        }
        
        var leftBraceIndex: Int = 0
        var rightBraceIndex: Int = 0
        var decls = [AnyDeclObject]()
        
        while true {
            if index >= tokens.count {
                throw Error("no extension body")
            }
            let token = tokens[index]
            if token.text == "{" {
                leftBraceIndex = index
                index += 1
                
                let bodyRet = try parseDecls(tokens: tokens, startIndex: index)
                index = bodyRet.endIndex
                decls = bodyRet.decls
                
                rightBraceIndex = index
                index += 1

                break
            } else {
                index += 1
            }
        }
        
        return (decl: ExtensionDecl(visibilityIndex: visibilityIndex.map { $0 - startIndex },
                                    keywordIndex: keywordIndex - startIndex,
                                    leadingTokens: Array(tokens[startIndex...leftBraceIndex]),
                                    isConformance: isConformance,
                                    decls: decls,
                                    rightBraceToken: tokens[rightBraceIndex]),
                endIndex: index)
    }
    
    func parsePropertyDecl(tokens: Array<TokenSyntax>, startIndex: Int) throws -> (decl: PropertyDecl, endIndex: Int)? {
        var index = startIndex
        
        var visibilityIndex: Int?
        while true {
            if index >= tokens.endIndex {
                return nil
            }
            let token = tokens[index]
            if visibilityKeywords.contains(token.text) {
                visibilityIndex = index
                index += 1
            } else if propertyKeywords.contains(token.text) {
                break
            } else {
                return nil
            }
        }
        
        let keywordIndex = index
        
        while true {
            if index >= tokens.endIndex {
                throw Error("no property brace")
            }
            let token = tokens[index]
            if token.text == "{" {
                let ret = parseBraceBlock(tokens: tokens, startIndex: index)
                index = ret
                break
            } else {
                index += 1
            }
        }
        
        return (decl: PropertyDecl(visibilityIndex: visibilityIndex.map { $0 - startIndex },
                                   keywordIndex: keywordIndex - startIndex,
                                   tokens: Array(tokens[startIndex..<index])),
                endIndex: index)
    }
    
    func parseUnknownDecl(tokens: Array<TokenSyntax>, startIndex: Int) -> (decl: UnknownDecl, endIndex: Int) {
        var index = startIndex
        while true {
            if index >= tokens.endIndex {
                break
            }
            let token = tokens[index]
            if token.text == "{" {
                let ret = parseBraceBlock(tokens: tokens, startIndex: index)
                index = ret
                break
            } else {
                index += 1
            }
        }
        
        return (decl: UnknownDecl(tokens: Array(tokens[startIndex..<index])),
                endIndex: index)
    }

    func parseBraceBlock(tokens: Array<TokenSyntax>, startIndex: Int) -> Int {
        var braceCount: Int = 0
        var index = startIndex
        
        while true {
            if index >= tokens.endIndex {
                break
            }
            let token = tokens[index]
            if token.text == "{" {
                braceCount += 1
                index += 1
            } else if token.text == "}" {
                braceCount -= 1
                index += 1
                if braceCount == 0 {
                    break
                }
            } else {
                index += 1
            }
        }
        
        return index
    }
    
}
