//
//  AllergyRequests.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 18.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Foundation
import Squid

struct GetAllergiesRequest: CustomJsonRequest {

    typealias Result = DataResult<Allergy>
    typealias DataResultType = Allergy
    
    var routes: HttpRoute {
        ["api", apiVersion, "allergies"]
    }
    var header: HttpHeader {
        [.apiKey: "\(userApiKey)"]
    }
}
struct PostAllergiesRequest: Request {

    let allergyIds: [UUID]
    typealias Result = Void
    
    var method: HttpMethod {
        .post
    }
    var body: HttpBody {
        HttpData.Json(["allergies": allergyIds])
    }
    var routes: HttpRoute {
        ["api", apiVersion, "allergies"]
    }
    var header: HttpHeader {
        [.apiKey: "\(userApiKey)"]
    }
}
struct PutAllergyRequest: Request {

    var allergyId: UUID
    typealias Result = Void
    
    var method: HttpMethod {
        .put
    }
    var body: HttpBody {
        HttpData.Json(["allergie_id": allergyId])
    }
    var routes: HttpRoute {
        ["api", apiVersion, "allergies"]
    }
    var header: HttpHeader {
        [.apiKey: "\(userApiKey)"]
    }
}
struct DeleteAllergyRequest: Request {

    var allergyId: UUID
    typealias Result = Void
    
    var method: HttpMethod {
        .delete
    }
    var routes: HttpRoute {
        ["api", apiVersion, "allergies", allergyId]
    }
    var header: HttpHeader {
        [.apiKey: "\(userApiKey)"]
    }
}
