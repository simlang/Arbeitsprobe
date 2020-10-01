//
//  ViewRouter.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 03.12.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class HomescreenViewRouter: ObservableObject {
    
    let objectWillChange = PassthroughSubject<HomescreenViewRouter, Never>()
    
    var currentPage: String = "page1" {
        didSet {
            withAnimation {
                objectWillChange.send(self)
            }
        }
    }
}
