import Foundation

let app = App(args: CommandLine.arguments)
guard try! app.main() else {
    exit(EXIT_FAILURE)
}

