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
    
    var decls: [AnyDeclObject] = []
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
        let parser = SyntaxParser()
        return try parser.parse(source: source)
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
                if let imp = decl.value as? ImportDecl {
                    if alreadyImported(imp) {
                        let trivia = imp.leadingTokens.first!.leadingTrivia + imp.leadingTokens.last!.trailingTrivia
                        if declIndex + 1 < source.decls.count {
                            let nextDecl = source.decls[declIndex + 1]
                            nextDecl.leadingTrivia = trivia + nextDecl.leadingTrivia
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
            ret.decls.append(AnyDeclObject(imp))
        }
        
        var endTrivia: Trivia = .zero
        for source in sources {
            if source.decls.count > 0 {
                let firstDecl = source.decls.first!
                
                firstDecl.leadingTrivia = endTrivia + firstDecl.leadingTrivia
                endTrivia = .zero
                
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
}
