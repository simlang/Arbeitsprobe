//
//  Food.swift
//  SliderQuestion
//
//  Created by Borchers, Alexander on 12.11.19.
//  Copyright © 2019 Borchers, Alexander. All rights reserved.
//

import Foundation

public struct Food {
    public let id: UUID
    let title: String
    let imageUrl: URL
    let foodSizes: [FoodSize]
    let possibleAllergies: [Allergy]
    
    init(id: UUID? = nil, title: String, imageUrl: URL, foodSizes: [FoodSize]? = nil, possibleAllergies: [Allergy]? = nil) {
        self.id = id ?? UUID()
        self.title = title
        self.imageUrl = imageUrl
        self.foodSizes = foodSizes ?? []
        self.possibleAllergies = possibleAllergies ?? []
    }
}

extension Food: Identifiable { }

extension Food: Equatable {
    public static func == (lhs: Food, rhs: Food) -> Bool {
        lhs.id == rhs.id
    }
}

extension Food: Codable {
    enum FoodCodingKeys: String, CodingKey {
        case id
        case title
        case imageUrl
        case allergies
        case sizes
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FoodCodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let title = try container.decode(String.self, forKey: .title)
        let imageUrlString = try container.decode(String.self, forKey: .imageUrl)
        
        var imageUrl = URL(string: "https://shiftytum.s3.eu-central-1.amazonaws.com/134778635815786763674")!
        if let convertedString = URL(string: imageUrlString) {
            imageUrl = convertedString
        }
        
        var allergies: [Allergy] = []
        do {
            allergies = try container.decode([Allergy].self, forKey: .allergies)
        } catch {
            // Do nothing
        }
           
        var sizes: [FoodSize] = []
        do {
            let sizesUnsorted = try container.decode([FoodSize].self, forKey: .sizes)
            sizes = sizesUnsorted.sorted(by: { $0.index > $1.index })
        } catch {
            // Do nothing
        }
        
        self.init(id: id,
                  title: title,
                  imageUrl: imageUrl,
                  foodSizes: sizes,
                  possibleAllergies: allergies)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FoodCodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.imageUrl, forKey: .imageUrl)
        try container.encode(self.foodSizes, forKey: .sizes)
        try container.encode(self.possibleAllergies, forKey: .allergies)
    }
}
