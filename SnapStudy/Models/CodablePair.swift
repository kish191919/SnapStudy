
// Models/CodablePair.swift
import Foundation

struct CodablePair: Codable {
    let first: Int
    let second: Int
    
    init(_ tuple: (Int, Int)) {
        self.first = tuple.0
        self.second = tuple.1
    }
    
    var tuple: (Int, Int) {
        return (first, second)
    }
}
