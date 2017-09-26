//
//  DeclObject.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/08.
//

import Foundation
import DebugReflect
import SwiftSyntax

protocol DeclObjectProtocol : class, DebugReflectable {
    func copy() -> Self
    var leadingTrivia: Trivia { get set }
    func write() -> String
}

final class AnyDeclObject : DeclObjectProtocol {
    init<X: DeclObjectProtocol>(_ x: X) {
        value = x
        _copy = { AnyDeclObject(x.copy()) }
        _leadingTrivia = { x.leadingTrivia }
        _setLeadingTrivia = { x.leadingTrivia = $0 }
        _write = { x.write() }
        _debugReflect = { x.debugReflect() }
    }
    
    let value: Any
    
    func copy() -> AnyDeclObject {
        return _copy()
    }
    
    var leadingTrivia: Trivia {
        get { return _leadingTrivia() }
        set { _setLeadingTrivia(newValue) }
    }
    
    func write() -> String {
        return _write()
    }
    
    func debugReflect() -> DebugReflectValue {
        return _debugReflect()
    }
    
    private var _copy: () -> AnyDeclObject
    private var _leadingTrivia: () -> Trivia
    private var _setLeadingTrivia: (Trivia) -> Void
    private var _write: () -> String
    private var _debugReflect: () -> DebugReflectValue
}

protocol LeadingTokensProtocol : DeclObjectProtocol {
    var leadingTokens: [TokenSyntax] { get set }
    var leadingTrivia: Trivia { get set }
    func write() -> String
}

extension LeadingTokensProtocol {
    var leadingTrivia: Trivia {
        get {
            return leadingTokens[0].leadingTrivia
        }
        set {
            var token = leadingTokens[0]
            token = token.withLeadingTrivia(newValue)
            leadingTokens[0] = token
        }
    }
    
    func write() -> String {
        return leadingTokens.map { String(describing: $0) }.joined()
    }
}

protocol VisibilityDeclProtocol {
    var visibility: TokenSyntax? { get }
    func setVisibility(tokenKind: TokenKind?)
}


