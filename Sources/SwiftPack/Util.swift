//
//  OptionalHandling.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/08.
//

import Foundation

func nonNil<T>(_ x: T?, _ reason: String) throws -> T {
    guard let x = x else {
        throw Error("non nil assertion failure: \(reason)")
    }
    return x
}

func findIndex<T>(_ x: Array<T>, _ pred: ((value: T, index: Int)) -> Bool) -> Int? {
    return findIndex(x, range: 0..<x.count, pred)
}

func findIndex<T>(_ xs: Array<T>, range: CountableRange<Int>, _ pred: ((value: T, index: Int)) -> Bool) -> Int? {
    for i in range {
        let x = xs[i]
        if pred((value: x, index: i)) {
            return i
        }
    }
    return nil
}

func run<R>(_ f: () throws -> R) rethrows -> R {
    return try f()
}

extension Array {
    func getOrNil(at: Index) -> Element? {
        return at < count ? self[at] : nil
    }
}

extension FileManager {
    func isDir(atPath path: String) -> Bool {
        var x = ObjCBool(false)
        return fileExists(atPath: path, isDirectory: &x) && x.boolValue
    }
    
    func swiftPaths(atPath path: String) throws -> [String] {
        let path = URL(fileURLWithPath: path)
        let files: [URL]
        if isDir(atPath: path.relativePath) {
            files = try subpathsOfDirectory(atPath: path.relativePath).map { URL(fileURLWithPath: $0) }
        } else {
            files = [path]
        }
        return files
            .filter { !isDir(atPath: path.appendingPathComponent($0.relativePath).relativePath) }
            .filter { $0.pathExtension == "swift" }
            .map { $0.relativePath }
    }
}
