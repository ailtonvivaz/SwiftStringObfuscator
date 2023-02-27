//
//  StringObfuscated.swift
//  
//
//  Created by Ailton Vieira Pinto Filho on 27/02/23.
//

import Foundation

public struct StringObfuscated: CustomStringConvertible {
    static var key: String?
    
    public var description: String {
        guard let key = Self.key else {
            fatalError("Key not been set")
        }
        
        return Obfuscator(with: key).reveal(key: bytes)
    }
    
    let bytes: [UInt8]
    
    public init(_ bytes: [UInt8]) {
        self.bytes = bytes
    }
}
