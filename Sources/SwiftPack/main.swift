import Foundation

let app = App()
guard try! app.main() else {
    exit(EXIT_FAILURE)
}

