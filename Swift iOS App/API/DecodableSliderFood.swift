//
//  Food.swift
//  SliderQuestion
//
//  Created by Borchers, Alexander on 12.11.19.
//  Copyright © 2019 Borchers, Alexander. All rights reserved.
//

import Foundation

public struct DecodableSliderFood {
    var value: Food
}

extension DecodableSliderFood: Decodable {
    enum FoodCodingKeys: String, CodingKey {
        case id
        case title
        case sizes
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FoodCodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let title = try container.decode(String.self, forKey: .title)
        
        let sizesUnsorted = try container.decode([FoodSize].self, forKey: .sizes)
        let sizes = sizesUnsorted.sorted(by: { $0.index < $1.index })
      
        self.value = Food(id: id, title: title, imageUrl: sizes.first!.imageUrl, foodSizes: sizes)
    }
}
