//
//  App.Swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/19.
//

import Foundation
import SwiftSyntax

class App {
    var args: [String] = []
    var mode: String = ""
    
    func main() throws -> Bool {
        args = Array(CommandLine.arguments)
        
        if args.count < 2 {
            print("not specified mode\n")
            printUsage()
            return false
        }
        
        mode = args[1]
        
        switch mode {
        case "unify":
            return try runUnifyMode()
        default:
            print("invalid mode\n")
            printUsage()
            return false
        }
    }
    
    func runUnifyMode() throws -> Bool {
        let fm = FileManager.default
        
        let dirArgs: [String] = Array(args[2...])
        guard dirArgs.count > 0 else {
            print("no directory specified")
            return false
        }
        
        let inputSourcePaths = try dirArgs.flatMap { (dirArg: String) -> [URL] in
            let paths = Array(try nonNil(fm.enumerator(atPath: dirArg), "enumerate: \(dirArg)"))
                .map { URL(fileURLWithPath: dirArg).appendingPathComponent($0 as! String) }
            let swiftPaths = paths.filter { $0.pathExtension == "swift" }
            return swiftPaths
        }
        
        let inputSources = try inputSourcePaths.map { try SourceFile.parse(path: $0) }
        let combinedSource = SourceFile.combine(inputSources)
        
        for decl in combinedSource.decls {
            switch decl {
            case let cls as ClassDecl:
                cls.setVisibility(tokenKind: TokenKind.fileprivateKeyword)
            case let fun as FuncDecl:
                fun.setVisibility(tokenKind: TokenKind.fileprivateKeyword)
            default:
                break
            }
        }
        
        print(combinedSource.write())
        
        return true
    }
    
    func printUsage() {
        print("""
[Usage] \(args[0]) <mode> [args...]
    unify mode:
        \(args[0]) unify [directory...]
""")
    }
}
