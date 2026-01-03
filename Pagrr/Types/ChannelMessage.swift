//
//  ChannelMessage.swift
//  Pagrr
//
//  Created by Valentin Lehmann on 01.01.26.
//

import Foundation

struct ChannelMessage: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var date: Date
    var urgent: Bool
}
