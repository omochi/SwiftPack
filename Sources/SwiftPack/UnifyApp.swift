//
//  UnifyApp.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/19.
//

import Foundation
import SwiftSyntax

class UnifyApp {
    init(args: [String]) {
        self.args = args
    }
    
    var args: [String]
    
    func main() throws -> Bool {
        let fm = FileManager.default
        
        let dirArgs: [URL] = args[2...].map { URL(fileURLWithPath: $0) }
        guard dirArgs.count > 0 else {
            print("no directory specified")
            return false
        }
                
        let inputSourcePaths: [URL] = try dirArgs
            .flatMap { dirArg in
                try fm.swiftPaths(atPath: dirArg.relativePath)
                    .map { dirArg.appendingPathComponent($0) } }
            .sorted { $0.path < $1.path }
        
        let inputSources: [SourceFile] = try inputSourcePaths.map { try SourceFile.parse(path: $0) }
        let combinedSource = SourceFile.combine(inputSources)
        
        for decl in combinedSource.decls {
            switch decl {
            case let ext as ExtensionDecl:
                if ext.isConformance {
                    ext.setVisibility(tokenKind: nil)
                } else {
                    ext.setVisibility(tokenKind: TokenKind.fileprivateKeyword)
                }
                
                for extDecl in ext.decls {
                    switch extDecl {
                    case let extVctr as VisibilityControllable:
                        extVctr.setVisibility(tokenKind: TokenKind.fileprivateKeyword)
                    default:
                        break
                    }
                }                
                
            case let vctr as VisibilityControllable:
                vctr.setVisibility(tokenKind: TokenKind.fileprivateKeyword)
            default:
                break
            }
        }
        
        print(combinedSource.write())
        
        return true
    }
}
