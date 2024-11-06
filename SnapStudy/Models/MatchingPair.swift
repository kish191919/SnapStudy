//
//  Models/MatchingPair.swift
import Foundation

struct MatchingPair: Identifiable {
    let id = UUID()
    let leftItem: String
    let leftIndex: Int
    let rightItem: String
    let rightIndex: Int
}
