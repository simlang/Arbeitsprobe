//
//  SurveyRequests.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 18.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Foundation
import Squid

struct GetSurveysRequest: CustomJsonRequest {

    typealias Result = DataResult<Survey>
    typealias DataResultType = Survey

    var routes: HttpRoute {
        ["api", apiVersion, "surveys"]
    }
    var header: HttpHeader {
        [.apiKey: "\(userApiKey)"]
    }
}

struct GetLatestSurveysRequest: CustomJsonRequest {

    typealias Result = DataResult<Survey>
    typealias DataResultType = Survey
    
    let latestSurveyId: String

    var routes: HttpRoute {
        ["api", apiVersion, "surveys"]
    }
    
    var query: HttpQuery {
        ["latest": latestSurveyId]
    }
    
    var header: HttpHeader {
        [.apiKey: "\(userApiKey)"]
    }
}

struct PostAnswerRequest: Request {
    
    var answerId: UUID
    var surveyId: UUID
    var questionId: UUID
    typealias Result = Void
    
    var method: HttpMethod {
        .post
    }
    var body: HttpBody {
        HttpData.Json(["data": "\(answerId)"])
    }
    var routes: HttpRoute {
        ["api", apiVersion, "surveys", surveyId, "questions", questionId, "answers"]
    }
    var header: HttpHeader {
        [.apiKey: "\(userApiKey)"]
    }
    var acceptedStatusCodes: CountableClosedRange<Int> {
        200...200
    }
}
struct PostMoodAnswerRequest: Request {
    
    var moodAnswers: [MoodAnswer]
    var surveyId: UUID
    
    typealias Result = Void
    
    var method: HttpMethod {
        .post
    }
    var body: HttpBody {
        HttpData.Json(["data": moodAnswers])
    }
    var routes: HttpRoute {
        ["api", apiVersion, "surveys", surveyId, "moods"]
    }
    var header: HttpHeader {
        [.apiKey: "\(userApiKey)"]
    }
    var acceptedStatusCodes: CountableClosedRange<Int> {
        200...200
    }
}
