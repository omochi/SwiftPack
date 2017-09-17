import Foundation
import SwiftSyntax

func main() throws {
    let args = Array<String>(CommandLine.arguments.dropFirst())
    if args.count < 1 {
        fatalError("not specified file")
    }

    let path = args[0]
    
    var sources = Array<SourceFile>()
    
    for fileAny in try nonNil(FileManager.default.enumerator(atPath: path), "enumerate dir: \(path)") {
        let file = URL(fileURLWithPath: path).appendingPathComponent(fileAny as! String)
        guard file.pathExtension == "swift" else {
            continue
        }
        sources.append(try SourceFile.parse(path: file))
    }
    
    let combinedFile = SourceFile.combine(sources)
    
    for decl in combinedFile.decls {
        if let cls = decl as? ClassDecl {
//            if cls.visibility == nil {
//                cls.setVisibility(tokenKind: TokenKind.fileprivateKeyword)
//            }
            if cls.visibility == nil || cls.visibility!.text == "public" {
                cls.setVisibility(tokenKind: TokenKind.fileprivateKeyword)
            }
        }
    }
    
    print(combinedFile.write())
}

try main()
