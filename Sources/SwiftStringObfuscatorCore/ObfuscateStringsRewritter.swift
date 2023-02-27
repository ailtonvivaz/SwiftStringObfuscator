//
//  ObfuscateStringsRewritter.swift
//  string_obfuscator
//
//  Created by Lukas Gergel on 01.01.2021.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

enum State {
    case reading
    case command
}

class ObfuscateStringsRewritter: SyntaxRewriter {
    let key: String
    
    var state: State = .reading
    
    init(key: String) {
        self.key = key
    }
    
    func integerLiteralElement(_ int: UInt8, addComma: Bool = true) -> ArrayElementSyntax {
        let literal = SyntaxFactory.makeIntegerLiteral("\(int)")
        return SyntaxFactory.makeArrayElement(
            expression: ExprSyntax(SyntaxFactory.makeIntegerLiteralExpr(digits: literal)),
            trailingComma: addComma ? SyntaxFactory.makeCommaToken(trailingTrivia: .spaces(1)) : nil)
    }
    
    override func visit(_ token: TokenSyntax) -> Syntax {
        let withoutSpaces = token.leadingTrivia.filter { if case .spaces = $0 { return false }; return true }
        guard withoutSpaces.count > 1 else { return super.visit(token) }
        let lastNewLine = withoutSpaces.last
        let commandLine = withoutSpaces[withoutSpaces.count-2]
        
        if state == .reading, case .newlines(1) = lastNewLine, case .lineComment("//:obfuscate") = commandLine {
            state = .command
        }
        return super.visit(token)
    }
    
    override open func visit(_ node: StringSegmentSyntax) -> Syntax {
        guard node.content.text.isEmpty == false else {
            state = .reading
            return super.visit(node)
        }
        
        guard case .command = state else { return super.visit(node) }
        
        let obfuscated = Obfuscator(with: key).bytesByObfuscatingString(string: node.content.text)
        
        let content = ExprSyntax(SyntaxFactory.makeArrayExpr(
            leftSquare: SyntaxFactory.makeLeftSquareBracketToken(),
            elements: SyntaxFactory.makeArrayElementList(obfuscated.enumerated().map({ index, byte in
                integerLiteralElement(byte, addComma: index != obfuscated.count - 1)
            })),
            rightSquare: SyntaxFactory.makeRightSquareBracketToken())
        )
        
        let functionCall = SyntaxFactory.makeFunctionCallExpr(
            calledExpression: ExprSyntax(
                SyntaxFactory.makeIdentifierExpr(
                    identifier: SyntaxFactory.makeIdentifier("StringObfuscated"),
                    declNameArguments: nil
                )
            ),
            leftParen: .leftParen,
            argumentList: SyntaxFactory.makeTupleExprElementList([
                SyntaxFactory.makeTupleExprElement(label: nil, colon: nil, expression: content, trailingComma: nil)
            ]),
            rightParen: .rightParen,
            trailingClosure: nil,
            additionalTrailingClosures: nil
        )
        
        let newExpr = SyntaxFactory.makeExpressionSegment(
            backslash: TokenSyntax.backslash,
            delimiter: nil,
            leftParen: .leftParen,
            expressions: SyntaxFactory.makeTupleExprElementList([
                SyntaxFactory.makeTupleExprElement(
                    label: nil,
                    colon: nil,
                    expression: ExprSyntax(functionCall),
                    trailingComma: nil
                )
            ]),
            rightParen: .rightParen
        )
        
        return super.visit(newExpr)
    }
}

struct FileHandlerOutputStream: TextOutputStream {
    private let fileHandle: FileHandle
    let encoding: String.Encoding
    
    init(_ fileHandle: FileHandle, encoding: String.Encoding = .utf8) {
        self.fileHandle = fileHandle
        self.encoding = encoding
    }
    
    mutating func write(_ string: String) {
        if let data = string.data(using: encoding) {
            fileHandle.write(data)
        }
    }
}
