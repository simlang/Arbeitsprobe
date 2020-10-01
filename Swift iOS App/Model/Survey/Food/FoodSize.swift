//
//  FoodSize.swift
//  sporthealth
//
//  Created by Jakob on 21.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Foundation

struct FoodSize {
    let id: UUID
    let title: String
    let index: Int
    let imageUrl: URL
}

extension FoodSize: Codable {
    enum FoodSizeCodingKeys: String, CodingKey {
        case id
        case title
        case index
        case imageUrl
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FoodSizeCodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let title = try container.decode(String.self, forKey: .title)
        let index = try container.decode(Int.self, forKey: .index)
        let imageUrlString = try container.decode(String.self, forKey: .imageUrl)
        
        var imageUrl = URL(string: "https://shiftytum.s3.eu-central-1.amazonaws.com/134778635815786763674")!
        if let convertedString = URL(string: imageUrlString) {
            imageUrl = convertedString
        }
        
        self.init(id: id,
                  title: title,
                  index: index,
                  imageUrl: imageUrl)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FoodSizeCodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.index, forKey: .index)
        try container.encode(self.imageUrl.absoluteString, forKey: .imageUrl)
    }
}
