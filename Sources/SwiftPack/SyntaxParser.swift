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

        let ret = try parseDecls(tokens: tokens)
        precondition(ret.decls.count == 1)
        if type(of: ret.decls[0]) == DeclObject.self {
            print("decl: \(type(of: decl)) =====")
            for i in 0..<tokens.count {
                print("  [\(i)]: \(type(of: tokens[i])) \(tokens[i])")
            }
            print("=====")
        }
        precondition(ret.index == tokens.count)
        return ret.decls[0]
    }
    
    func parseDecls(tokens: [TokenSyntax]) throws -> (index: Int, decls: [DeclObject]) {
        var index = 0
        var declStartIndex = index
        var decls = [DeclObject]()
        
        func appendDecl(_ decl: DeclObject, index idx: Int) {
            index = idx
            decls.append(decl)
            declStartIndex = idx
        }
        
        while true {
            if index >= tokens.count {
                let declTokens = Array(tokens[declStartIndex..<tokens.count])
                if declTokens.count > 0 {
//                    print("unknown decl")
//                    for i in 0..<tokens.count {
//                        print("  tokens[\(i)] \(type(of: tokens[i])) [\(tokens[i])]")
//                    }
//                    
                    let unknown = DeclObject(tokens: Array(SyntaxFactory.makeTokenList(declTokens)))
                    decls.append(unknown)
                    declStartIndex = index
                }
                break
            }
            let token = tokens[index]
            let text = token.text
            if text == "{" {
                let ret = parseBraceBody(tokens: tokens, startIndex: index)
                index = ret
            } else if text == "}" {
                break
            } else if classKeywords.contains(text) {
                let ret = try parseClassDecl(tokens: tokens, startIndex: declStartIndex)
                appendDecl(ret.decl, index: ret.endIndex)
            } else if text == "import" {
                let ret = try parseImportDecl(tokens: tokens, startIndex: declStartIndex)
                appendDecl(ret.decl, index: ret.endIndex)
            } else if text == "func" {
                let ret = try parseFuncDecl(tokens: tokens, startIndex: declStartIndex)
                appendDecl(ret.decl, index: ret.endIndex)
            } else if text == "typealias" {
                let ret = try parseTypeAliasDecl(tokens: tokens, startIndex: declStartIndex)
                appendDecl(ret.decl, index: ret.endIndex)
            } else if text == "extension" {
                let ret = try parseExtensionDecl(tokens: tokens, startIndex: declStartIndex)
                appendDecl(ret.decl, index: ret.endIndex)
            } else {
                index += 1
            }
        }
        
        return (index: index, decls: decls)
    }
    
    func parseClassDecl(tokens: [TokenSyntax], startIndex: Int) throws -> (endIndex: Int, decl: ClassDecl) {
        var index = startIndex
        
        var visibilityIndex: Int?
        var keywordIndex: Int = 0
        var nameIndex: Int = 0
        while true {
            precondition(index < tokens.count, "no class keyword")
            let token = tokens[index]

            if visibilityKeywords.contains(token.text) {
                visibilityIndex = index
                index += 1
            } else if classKeywords.contains(token.text) {
                keywordIndex = index
                nameIndex = index + 1
                index += 2
            } else if token.text == "{" {
                let ret = parseBraceBody(tokens: tokens, startIndex: index)
                index = ret
                break
            } else {
                index += 1
            }
        }
        
        return (endIndex: index,
                decl: ClassDecl(visibilityIndex: visibilityIndex,
                                keywordIndex : keywordIndex,
                                nameIndex: nameIndex,
                                tokens: Array(tokens[startIndex..<index])))
    }
    
    func parseImportDecl(tokens: [TokenSyntax], startIndex: Int) throws -> (endIndex: Int, decl: ImportDecl) {
        var index = startIndex
        
        var keywordIndex: Int = 0
        var nameIndex: Int = 0
        while true {
            precondition(index < tokens.count, "no import keyword")
            let token = tokens[index]
            
            if token.text == "import" {
                keywordIndex = index
                nameIndex = index + 1
                index += 2
                break
            } else {
                index += 1
            }
        }
        
        return (endIndex: index,
                decl: ImportDecl(keywordIndex : keywordIndex,
                                 nameIndex: nameIndex,
                                 tokens: Array(tokens[startIndex..<index])))
    }
    
    func parseFuncDecl(tokens: [TokenSyntax], startIndex: Int) throws -> (endIndex: Int, decl: FuncDecl) {
        var index = startIndex
        
        var visibilityIndex: Int?
        var keywordIndex: Int = 0
        var nameIndex: Int = 0
        while true {
            precondition(index < tokens.count, "no func keyword")
            let token = tokens[index]
            
            if visibilityKeywords.contains(token.text) {
                visibilityIndex = index
                index += 1
            } else if token.text == "func" {
                keywordIndex = index
                nameIndex = index + 1
                index += 2
            } else if token.text == "{" {
                let ret = parseBraceBody(tokens: tokens, startIndex: index)
                index = ret
                break
            } else {
                index += 1
            }
        }
        
        return (endIndex: index,
                decl: FuncDecl(visibilityIndex: visibilityIndex,
                               keywordIndex : keywordIndex,
                               nameIndex: nameIndex,
                               tokens: Array(tokens[startIndex..<index])))
    }
    
    
    func parseTypeAliasDecl(tokens: [TokenSyntax], startIndex: Int) throws -> (endIndex: Int, decl: TypeAliasDecl) {
        var index = startIndex
        
        var visibilityIndex: Int?
        var keywordIndex: Int = 0

        while true {
            precondition(index < tokens.count, "no typealias keyword")
            let token = tokens[index]
            
            if visibilityKeywords.contains(token.text) {
                visibilityIndex = index
                index += 1
            } else if token.text == "typealias" {
                keywordIndex = index
                index += 4
                break
            } else {
                index += 1
            }
        }
        
        return (endIndex: index,
                decl: TypeAliasDecl(visibilityIndex: visibilityIndex,
                                    keywordIndex : keywordIndex,
                                    tokens: Array(tokens[startIndex..<index])))
    }
    
    
    func parseExtensionDecl(tokens: [TokenSyntax], startIndex: Int) throws -> (endIndex: Int, decl: ExtensionDecl) {
        var index = startIndex
        
        var visibilityIndex: Int?
        var keywordIndex: Int = 0
        var leftBraceIndex: Int = 0
        var rightBraceIndex: Int = 0
        while true {
            precondition(index < tokens.count, "no extension keyword")
            let token = tokens[index]
            
            if visibilityKeywords.contains(token.text) {
                visibilityIndex = index
                index += 1
            } else if token.text == "extension" {
                keywordIndex = index
                index += 1
            } else if token.text == "{" {
                leftBraceIndex = index
                let ret = parseBraceBody(tokens: tokens, startIndex: index)
                rightBraceIndex = ret - 1
                index = ret
                break
            } else {
                index += 1
            }
        }
        
        return (endIndex: index,
                decl: ExtensionDecl(visibilityIndex: visibilityIndex,
                                    keywordIndex: keywordIndex,
                                    tokens: Array(tokens[startIndex...leftBraceIndex]),
                                    rightBraceToken: tokens[rightBraceIndex]))
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
                braceCount -= 1
                index += 1
                if braceCount <= 0 {
                    return index
                }
            } else {
                index += 1
            }
        }
    }
    
}
