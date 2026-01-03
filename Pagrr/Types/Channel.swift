//
//  Channel.swift
//  Pagrr
//
//  Created by Valentin Lehmann on 01.01.26.
//

import Foundation

struct Channel: Identifiable, Codable {
    var id: String
    var name: String
    var createdAt: Date
    var owners: [String]
    var apiKey: String
}
