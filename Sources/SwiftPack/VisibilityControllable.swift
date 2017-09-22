//
//  VisibilityControllable.swift
//  SwiftPack
//
//  Created by omochimetaru on 2017/09/22.
//

import Foundation
import SwiftSyntax

protocol VisibilityControllable {
    var visibility: TokenSyntax? { get }
    func setVisibility(tokenKind: TokenKind?)
}
