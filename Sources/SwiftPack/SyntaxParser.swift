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
    
    func parseTopDecl(_ decl: DeclSyntax) throws -> DeclObject {
        let tokens = Array(decl.children.map { $0 as! TokenSyntax })

        let ret = try parseDecls(tokens: tokens, startIndex: 0)
        precondition(ret.decls.count == 1)
        
        if ret.endIndex != tokens.count {
            print("parse top decl erorr: \(ret.endIndex), \(tokens.count)")
        }
        precondition(ret.endIndex == tokens.count)
        return ret.decls[0]
    }
    
    func parseDecls(tokens: [TokenSyntax], startIndex: Int) throws -> (endIndex: Int, decls: [DeclObject]) {
        var index = startIndex
        var decls = [DeclObject]()
        
        func appendDecl(_ decl: DeclObject, index newIndex: Int) {
            index = newIndex
            decls.append(decl)
        }
        
        while true {
            if index >= tokens.count {
                break
            }
            let token = tokens[index]
            
            if let ret = try parseClassDecl(tokens: tokens, startIndex: index) {
                appendDecl(ret.decl, index: ret.endIndex)
            } else if let ret = try parseImportDecl(tokens: tokens, startIndex: index) {
                appendDecl(ret.decl, index: ret.endIndex)
            } else if let ret = try parseFuncDecl(tokens: tokens, startIndex: index) {
                appendDecl(ret.decl, index: ret.endIndex)
            } else if let ret = try parseTypeAliasDecl(tokens: tokens, startIndex: index) {
                appendDecl(ret.decl, index: ret.endIndex)
            } else if let ret = try parseExtensionDecl(tokens: tokens, startIndex: index) {
                appendDecl(ret.decl, index: ret.endIndex)
            } else if let ret = try parsePropertyDecl(tokens: tokens, startIndex: index) {
                appendDecl(ret.decl, index: ret.endIndex)
            } else if token.text == "}" {
                break
            } else {
                let ret = parseUnknownDecl(tokens: tokens, startIndex: index)
                appendDecl(ret.decl, index: ret.endIndex)
                
                let unknownTokens = ret.decl.tokens
                print("===unknown decl===")
                for i in 0..<unknownTokens.count {
                    print("  \(type(of: unknownTokens[i])): [\(unknownTokens[i])]")
                }
                print("===")
            }
        }
        
        return (endIndex: index, decls: decls)
    }
    
    func parseClassDecl(tokens: [TokenSyntax], startIndex: Int) throws -> (endIndex: Int, decl: ClassDecl)? {
        var index = startIndex
        
        var visibilityIndex: Int?

        while true {
            if index >= tokens.count {
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
        let nameIndex: Int = index + 1
        index += 2
        
        while true {
            if index >= tokens.endIndex {
                throw Error("no class body")
            }
            let token = tokens[index]
            
            if token.text == "{" {
                index = parseBraceBody(tokens: tokens, startIndex: index + 1) + 1
                break
            } else {
                index += 1
            }
        }
        
        return (endIndex: index,
                decl: ClassDecl(visibilityIndex: visibilityIndex.map { $0 - startIndex },
                                keywordIndex : keywordIndex - startIndex,
                                nameIndex: nameIndex - startIndex,
                                tokens: Array(tokens[startIndex..<index])))
    }
    
    func parseImportDecl(tokens: [TokenSyntax], startIndex: Int) throws -> (endIndex: Int, decl: ImportDecl)? {
        var index = startIndex
        
        while true {
            if index >= tokens.count {
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
        let nameIndex: Int = index + 1
        index += 2
    
        return (endIndex: index,
                decl: ImportDecl(keywordIndex : keywordIndex - startIndex,
                                 nameIndex: nameIndex - startIndex,
                                 tokens: Array(tokens[startIndex..<index])))
    }
    
    func parseFuncDecl(tokens: [TokenSyntax], startIndex: Int) throws -> (endIndex: Int, decl: FuncDecl)? {
        var index = startIndex
        
        var visibilityIndex: Int?
        while true {
            if index >= tokens.count {
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
        let nameIndex: Int = index + 1
        index += 2

        while true {
            if index >= tokens.count {
                throw Error("no func body")
            }
            let token = tokens[index]
            if token.text == "{" {
                index = parseBraceBody(tokens: tokens, startIndex: index + 1) + 1
                break
            } else {
                index += 1
            }
        }
        
        return (endIndex: index,
                decl: FuncDecl(visibilityIndex: visibilityIndex.map { $0 - startIndex },
                               keywordIndex : keywordIndex - startIndex,
                               nameIndex: nameIndex - startIndex,
                               tokens: Array(tokens[startIndex..<index])))
    }
    
    func parseTypeAliasDecl(tokens: [TokenSyntax], startIndex: Int) throws -> (endIndex: Int, decl: TypeAliasDecl)? {
        var index = startIndex
        
        var visibilityIndex: Int?
        while true {
            if index >= tokens.count {
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
        
        return (endIndex: index,
                decl: TypeAliasDecl(visibilityIndex: visibilityIndex.map { $0 - startIndex },
                                    keywordIndex : keywordIndex - startIndex,
                                    tokens: Array(tokens[startIndex..<index])))
    }
    
    func parseExtensionDecl(tokens: [TokenSyntax], startIndex: Int) throws -> (endIndex: Int, decl: ExtensionDecl)? {
        var index = startIndex
        
        var visibilityIndex: Int?
        while true {
            if index >= tokens.count {
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
            if index >= tokens.count {
                break
            }
            let token = tokens[index]
            if token.text == "{" {
                break
            } else if token.text == ":" {
                index += 1
                isConformance = true
                break
            } else {
                break
            }
        }
        
        print("isConformance: \(isConformance)")
        
        var leftBraceIndex: Int = 0
        var rightBraceIndex: Int = 0
        var decls = [DeclObject]()
        
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
                
//                print("===body===")
//                for i in 0..<bodyRet.decls.count {
//                    print("[\(i)], \(bodyRet.decls[i])")
//                }
                
                decls = bodyRet.decls
                
                rightBraceIndex = index
                index += 1

                break
            } else {
                index += 1
            }
        }
        
        return (endIndex: index,
                decl: ExtensionDecl(visibilityIndex: visibilityIndex.map { $0 - startIndex },
                                    keywordIndex: keywordIndex - startIndex,
                                    tokens: Array(tokens[startIndex...leftBraceIndex]),
                                    isConformance: isConformance,
                                    decls: decls,
                                    rightBraceToken: tokens[rightBraceIndex]))
    }
    
    func parsePropertyDecl(tokens: [TokenSyntax], startIndex: Int) throws -> (endIndex: Int, decl: PropertyDecl)? {
        var index = startIndex
        
        var visibilityIndex: Int?
        while true {
            if index >= tokens.count {
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
            if index >= tokens.count {
                fatalError("no property brace")
            }
            let token = tokens[index]
            if token.text == "{" {
                index += 1
                
                index = parseBraceBody(tokens: tokens, startIndex: index)
                index += 1
                break
            } else {
                index += 1
            }
        }
        
        return (endIndex: index,
                decl: PropertyDecl(visibilityIndex: visibilityIndex,
                                   keywordIndex: keywordIndex,
                                   tokens: Array(tokens[startIndex..<index])))
        
        
    }
    
    func parseUnknownDecl(tokens: [TokenSyntax], startIndex: Int) -> (endIndex: Int, decl: UnknownDecl) {
        var index = startIndex
        while true {
            if index >= tokens.count {
                index = tokens.count
                break
            }
            let token = tokens[index]
            if token.text == "{" {
                index = parseBraceBody(tokens: tokens, startIndex: index + 1) + 1
                break
            } else {
                index += 1
            }
        }
        
        let remTokens = Array(tokens[startIndex..<index])
        return (endIndex: index,
                decl: UnknownDecl(tokens: remTokens))
    }

    func parseBraceBody(tokens: [TokenSyntax], startIndex: Int) -> Int {
        var braceCount: Int = 0
        var index = startIndex
        while true {
            if index >= tokens.count {
                return tokens.count
            }
            let token = tokens[index]
            if token.text == "{" {
                braceCount += 1
                index += 1
            } else if token.text == "}" {
                if braceCount == 0 {
                    return index
                }
                braceCount -= 1
                index += 1
            } else {
                index += 1
            }
        }
    }
    
}
