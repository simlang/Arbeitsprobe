//
//  UserRequest.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 10.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Foundation
import Squid

let apiVersion = "v1"
var userApiKey: String {
    UserDefaults.standard.string(forKey: "apiKey") ?? ""
}

struct DataResult<Result>: Decodable where Result: Decodable {
    let data: [Result]
}

struct DataResultWithoutArray<Result>: Decodable where Result: Decodable {
    let data: Result
}

protocol CustomJsonRequest: JsonRequest where Result == DataResult<DataResultType> {
    associatedtype DataResultType: Decodable
}

protocol CustomJsonWithoutArrayRequest: JsonRequest where Result == DataResultWithoutArray<DataResultType> {
    associatedtype DataResultType: Decodable
}
