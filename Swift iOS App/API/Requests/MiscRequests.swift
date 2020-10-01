//
//  MiscRequests.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 18.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Foundation
import Squid

struct GetStatsRequest: CustomJsonWithoutArrayRequest {

    typealias Result = DataResultWithoutArray<UserStats>
    typealias DataResultType = UserStats

    var routes: HttpRoute {
        ["api", apiVersion, "stats"]
    }
    var header: HttpHeader {
        [.apiKey: "\(userApiKey)"]
    }
}

struct GetUsersFromMockApiRequest: JsonRequest {

    typealias Result = [User]

    var routes: HttpRoute {
        ["users"]
    }
}

struct PostDeviceIdRequest: Request {
    
    var deviceId: String
    typealias Result = Void
    
    var method: HttpMethod {
        .post
    }
    var body: HttpBody {
        HttpData.Json(["device_id": "\(deviceId)"])
    }
    var routes: HttpRoute {
        ["api", apiVersion, "profile"]
    }
    var header: HttpHeader {
        [.apiKey: "\(userApiKey)"]
    }
}
