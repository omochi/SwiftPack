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

        let ret = try parseDecls(tokens: tokens[...])
        precondition(ret.decls.count == 1)
        
        if ret.rest.count != 0 {
            print("parse top decl error: rest index=\(ret.rest.startIndex)..<\(ret.rest.endIndex)")
        }
        return ret.decls[0]
    }
    
    func parseDecls(tokens: ArraySlice<TokenSyntax>) throws -> (decls: [AnyDeclObject], rest: ArraySlice<TokenSyntax>) {
        var index = tokens.startIndex
        var decls = [AnyDeclObject]()
        
        func appendDecl<X: DeclObjectProtocol>(_ x: (decl: X, rest: ArraySlice<TokenSyntax>)) {
            decls.append(AnyDeclObject(x.decl))
            index = x.rest.startIndex
        }
        
        while true {
            if index >= tokens.endIndex {
                break
            }
            let token = tokens[index]
            
            if let ret = try parseClassDecl(tokens: tokens[index...]) {
                appendDecl(ret)
            } else if let ret = try parseImportDecl(tokens: tokens[index...]) {
                appendDecl(ret)
            } else if let ret = try parseFuncDecl(tokens: tokens[index...]) {
                appendDecl(ret)
            } else if let ret = try parseTypeAliasDecl(tokens: tokens[index...]) {
                appendDecl(ret)
            } else if let ret = try parseExtensionDecl(tokens: tokens[index...]) {
                appendDecl(ret)
            } else if let ret = try parsePropertyDecl(tokens: tokens[index...]) {
                appendDecl(ret)
            } else if token.text == "}" {
                break
            } else {
                let ret = parseUnknownDecl(tokens: tokens[index...])
                appendDecl(ret)
                
                let unknownTokens = ret.decl.leadingTokens
                print("===unknown decl===")
                for i in 0..<unknownTokens.count {
                    print("  \(type(of: unknownTokens[i])): [\(unknownTokens[i])]")
                }
                print("===")
            }
        }
        
        return (decls: decls, rest: tokens[index...])
    }
    
    func parseClassDecl(tokens: ArraySlice<TokenSyntax>) throws -> (decl: ClassDecl, rest: ArraySlice<TokenSyntax>)? {
        var index = tokens.startIndex
        
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
                let ret = parseBraceBlock(tokens: tokens[index...])
                index = ret.startIndex
                break
            } else {
                index += 1
            }
        }
        
        return (decl: ClassDecl(visibilityIndex: visibilityIndex.map { $0 - tokens.startIndex },
                                keywordIndex: keywordIndex - tokens.startIndex,
                                nameIndex: nameIndex - tokens.startIndex,
                                tokens: Array(tokens[..<index])),
                rest: tokens[index...])
    }
    
    func parseImportDecl(tokens: ArraySlice<TokenSyntax>) throws -> (decl: ImportDecl, rest: ArraySlice<TokenSyntax>)? {
        var index = tokens.startIndex
        
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

        return (decl: ImportDecl(keywordIndex: keywordIndex - tokens.startIndex,
                                 nameIndex: nameIndex - tokens.startIndex,
                                 tokens: Array(tokens[..<index])),
                rest: tokens[index...])
    }
    
    func parseFuncDecl(tokens: ArraySlice<TokenSyntax>) throws -> (decl: FuncDecl, rest: ArraySlice<TokenSyntax>)? {
        var index = tokens.startIndex

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
                let ret = parseBraceBlock(tokens: tokens[index...])
                index = ret.startIndex
                break
            } else {
                index += 1
            }
        }
        
        return (decl: FuncDecl(visibilityIndex: visibilityIndex.map { $0 - tokens.startIndex },
                               keywordIndex : keywordIndex - tokens.startIndex,
                               nameIndex: nameIndex - tokens.startIndex,
                               tokens: Array(tokens[..<index])),
                rest: tokens[index...])
    }
    
    func parseTypeAliasDecl(tokens: ArraySlice<TokenSyntax>) throws -> (decl: TypeAliasDecl, rest: ArraySlice<TokenSyntax>)? {
        var index = tokens.startIndex
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
        
        return (decl: TypeAliasDecl(visibilityIndex: visibilityIndex.map { $0 - tokens.startIndex },
                                    keywordIndex : keywordIndex - tokens.startIndex,
                                    tokens: Array(tokens[..<index])),
                rest: tokens[index...])
    }
    
    func parseExtensionDecl(tokens: ArraySlice<TokenSyntax>) throws -> (decl: ExtensionDecl, rest: ArraySlice<TokenSyntax>)? {
        var index = tokens.startIndex
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
                
                let bodyRet = try parseDecls(tokens: tokens[index...])
                index = bodyRet.rest.startIndex
                decls = bodyRet.decls
                
                rightBraceIndex = index
                index += 1

                break
            } else {
                index += 1
            }
        }
        
        return (decl: ExtensionDecl(visibilityIndex: visibilityIndex.map { $0 - tokens.startIndex },
                                    keywordIndex: keywordIndex - tokens.startIndex,
                                    leadingTokens: Array(tokens[...leftBraceIndex]),
                                    isConformance: isConformance,
                                    decls: decls,
                                    rightBraceToken: tokens[rightBraceIndex]),
                rest: tokens[index...])
    }
    
    func parsePropertyDecl(tokens: ArraySlice<TokenSyntax>) throws -> (decl: PropertyDecl, rest: ArraySlice<TokenSyntax>)? {
        var index = tokens.startIndex
        
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
                let ret = parseBraceBlock(tokens: tokens[index...])
                index = ret.startIndex
                break
            } else {
                index += 1
            }
        }
        
        return (decl: PropertyDecl(visibilityIndex: visibilityIndex.map { $0 - tokens.startIndex },
                                   keywordIndex: keywordIndex - tokens.startIndex,
                                   tokens: Array(tokens[..<index])),
                rest: tokens[index...])
    }
    
    func parseUnknownDecl(tokens: ArraySlice<TokenSyntax>) -> (decl: UnknownDecl, rest: ArraySlice<TokenSyntax>) {
        var index = tokens.startIndex
        while true {
            if index >= tokens.endIndex {
                break
            }
            let token = tokens[index]
            if token.text == "{" {
                let ret = parseBraceBlock(tokens: tokens[index...])
                index = ret.startIndex
                break
            } else {
                index += 1
            }
        }
        
        return (decl: UnknownDecl(tokens: Array(tokens[..<index])),
                rest: tokens[index...])
    }

    func parseBraceBlock(tokens: ArraySlice<TokenSyntax>) -> ArraySlice<TokenSyntax> {
        var braceCount: Int = 0
        var index = tokens.startIndex
        
        while true {
            if index >= tokens.endIndex {
                return tokens[index...]
            }
            let token = tokens[index]
            if token.text == "{" {
                braceCount += 1
                index += 1
            } else if token.text == "}" {
                braceCount -= 1
                index += 1
                if braceCount == 0 {
                    return tokens[index...]
                }
            } else {
                index += 1
            }
        }
    }
    
}
