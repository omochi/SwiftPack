//
//  App.Swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/19.
//

import Foundation
import SwiftSyntax

class App {
    init(args: [String]) {
        self.args = args
    }
    
    var args: [String]
    
    func main() throws -> Bool {
        if args.count < 2 {
            print("not specified mode\n")
            printUsage()
            return false
        }
                
        switch args[1] {
        case "unify":
            let unify = UnifyApp(args: args)
            return try unify.main()
        default:
            print("invalid mode\n")
            printUsage()
            return false
        }
    }
    
    func printUsage() {
        print("""
[Usage] \(args[0]) <mode> [args...]
    unify mode:
        \(args[0]) unify [directory...]
""")
    }
}
