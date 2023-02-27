//
//  StringObfuscator.swift
//
//
//  Created by Lukas Gergel on 02.01.2021.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxParser

public class StringObfuscator {
    public static func getObfuscatedContent(for sourceFile: URL, and key: String) throws -> String {
        let sourceFile = try SyntaxParser.parse(sourceFile)
        var output = ""
        let obfuscated = ObfuscateStringsRewritter(key: key).visit(sourceFile)
        obfuscated.write(to: &output)
        return output
    }
    
    public static func obfuscateContent(sourceFile: URL, targetFile: URL, key: String) throws {
        let sourceFile = try SyntaxParser.parse(sourceFile)
        let fileHandle = try FileHandle(forWritingTo: targetFile)
        var output = FileHandlerOutputStream(fileHandle)
        let obfuscated = ObfuscateStringsRewritter(key: key).visit(sourceFile)
        obfuscated.write(to: &output)
    }
}
