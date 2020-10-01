//
//  Allergy.swift
//  sporthealth
//
//  Created by Borchers, Alexander on 02.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Foundation

public struct Allergy {
    public let id: UUID
    let name: String
    let title: String
    let description: String
    
    init(id: UUID? = nil, name: String, description: String = "", title: String = "") {
        self.id = id ?? UUID()
        self.name = name
        self.title = title
        self.description = description
    }
}

extension Allergy: Identifiable { }

extension Allergy: Equatable {
    public static func == (lhs: Allergy, rhs: Allergy) -> Bool {
        lhs.id == rhs.id
    }
}

extension Allergy: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Allergy: Decodable {
    enum AllergyCodingKeys: String, CodingKey {
      //Question:
      case id
      case name
      case title
    }
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: AllergyCodingKeys.self)
      let id = try container.decode(UUID.self, forKey: .id)
      let name = try container.decode(String.self, forKey: .name)
      let title = try container.decode(String.self, forKey: .title)
      
      self.init(id: id,
                name: name,
                title: title)
    }
}

extension Allergy: Encodable {}
