//
//  AvoidableFoodRequests.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 18.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Foundation
import Squid

struct GetAvoidableFoodsRequest: CustomJsonRequest {
    
    typealias Result = DataResult<Food>
    typealias DataResultType = Food
    
    var routes: HttpRoute {
        ["api", apiVersion, "avoided-foods"]
    }
    var header: HttpHeader {
        [.apiKey: "\(userApiKey)"]
    }
}
struct PostAvoidableFoodsRequest: Request {
    
    var avoidedFoodIds: [UUID]
    typealias Result = Void
    
    var method: HttpMethod {
        .post
    }
    var body: HttpBody {
        HttpData.Json(["foods": avoidedFoodIds])
    }
    var routes: HttpRoute {
        ["api", apiVersion, "avoided-foods"]
    }
    var header: HttpHeader {
        [.apiKey: "\(userApiKey)"]
    }
}
struct PutAvoidableFoodRequest: Request {

    var avoidedFoodId: UUID
    typealias Result = Void
    
    var method: HttpMethod {
        .put
    }
    var body: HttpBody {
        HttpData.Json(["food_id": "\(avoidedFoodId)"])
    }
    var routes: HttpRoute {
        ["api", apiVersion, "avoided-foods"]
    }
    var header: HttpHeader {
        [.apiKey: "\(userApiKey)"]
    }
}
struct DeleteAvoidableFoodRequest: Request {

    var avoidedFoodId: UUID
    typealias Result = Void
    
    var method: HttpMethod {
        .delete
    }
    var routes: HttpRoute {
        ["api", apiVersion, "avoided-foods", avoidedFoodId]
    }
    var header: HttpHeader {
        [.apiKey: "\(userApiKey)"]
    }
}
