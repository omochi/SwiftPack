//
//  SourceFile.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/08.
//

import Foundation
import SwiftSyntax
import DebugReflect

class SourceFile : DebugReflectable {
    init() {}
    
    init(copy: SourceFile) {
        decls = copy.decls.map { $0.copy() }
        eofToken = copy.eofToken.withKind(copy.eofToken.tokenKind)
    }
    
    var decls: [DeclObject] = []
    var eofToken: TokenSyntax = SyntaxFactory.makeToken(.eof, presence: .present,
                                                        leadingTrivia: .zero, trailingTrivia: .zero)

    func debugReflect() -> DebugReflectValue {
        return .build { b in
            b.field("decls", decls)
        }
    }
    
    func write() -> String {
        return decls.map { $0.write() }.joined() + eofToken.description
    }
    
    static func parse(path: URL) throws -> SourceFile {
        let source = try Syntax.parse(path)
        let ret = SourceFile()
        try ret.parse(source: source)
        return ret
    }
    
    static func combine(_ sources: [SourceFile]) -> SourceFile {
        let sources = sources.map { SourceFile(copy: $0) }
        
        let ret = SourceFile()
        
        var importDecls = Array<ImportDecl>()
        func alreadyImported(_ decl: ImportDecl) -> Bool {
            let name = decl.name.text
            return importDecls.contains {
                $0.name.text == name
            }
        }
        
        for source in sources {
            var declIndex = 0
            while declIndex < source.decls.count {
                let decl = source.decls[declIndex]
                if let imp = decl as? ImportDecl {
                    if alreadyImported(imp) {
                        let trivia = imp.tokens.first!.leadingTrivia + imp.tokens.last!.trailingTrivia
                        if declIndex + 1 < source.decls.count {
                            let nextDecl = source.decls[declIndex + 1]
                            var firstToken = nextDecl.tokens[0]
                            firstToken = firstToken.withLeadingTrivia(trivia + firstToken.leadingTrivia)
                            nextDecl.tokens[0] = firstToken
                        } else {
                            source.eofToken = source.eofToken.withLeadingTrivia(trivia + source.eofToken.leadingTrivia)
                        }
                    } else {
                        importDecls.append(imp)
                    }
                    
                    source.decls.remove(at: declIndex)
                    
                    continue
                }
                
                declIndex += 1
            }
        }
        
        for imp in importDecls {
            ret.decls.append(imp)
        }
        
        var endTrivia: Trivia = .zero
        for source in sources {
            if source.decls.count > 0 {
                let firstDecl = source.decls.first!
                
                run {
                    var firstToken = firstDecl.tokens[0]
                    firstToken = firstToken.withLeadingTrivia(endTrivia + firstToken.leadingTrivia)
                    firstDecl.tokens[0] = firstToken
                    endTrivia = .zero
                }
                
                for decl in source.decls {
                    ret.decls.append(decl)
                }
            }

            endTrivia = endTrivia + source.eofToken.leadingTrivia
        }
        
        ret.eofToken = SyntaxFactory.makeToken(.eof, presence: .present,
                                               leadingTrivia: endTrivia, trailingTrivia: .zero)
        
        return ret
    }
    
    private func parse(source: SourceFileSyntax) throws {
        for decl in source.topLevelDecls {
            let decl = try parse(decl: decl)
            decls.append(decl)
        }
        eofToken = source.eofToken
    }
    
    private func parse(decl: DeclSyntax) throws -> DeclObject {
        let tokens = Array(decl.children.map { $0 as! TokenSyntax })
        for token in tokens {
            if token.text == "{" {
                break
            } else if classKeywords.contains(token.text) {
                return try ClassDecl.parse(node: decl)
            } else if token.text == "import" {
                return try ImportDecl.parse(node: decl)
            } else if token.text == "func" {
                return try FuncDecl.parse(node: decl)
            }
        }
        
//        print("unknown decl")
//        print(decl.description)
        return DeclObject(tokens: Array(SyntaxFactory.makeTokenList(tokens)))
    }
}
