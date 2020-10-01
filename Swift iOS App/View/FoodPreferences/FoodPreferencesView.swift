//
//  FoodPreferencesView.swift
//  sporthealth
//
//  Created by Borchers, Alexander on 25.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI
import Combine

struct FoodPreferencesView: View {
    @EnvironmentObject private var userProfileModel: UserProfileModel
    
    let columns = 2
    //foods array + init
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Text("Gibt es Lebensmittel, die du vermeidest?")
                    .textHeadlineModifier()
                Spacer()
                    .frame(height: 20)
                ScrollView(.vertical) {
                    ForEach(0..<self.getRowCount()) { row in
                        HStack {
                            ForEach(0..<self.getColumnsForThisRow(row)) { column in
                                FoodGridItemView(food: self.userProfileModel.avoidableFoods[self.getIndex(row, column)])
                                    .frame(minWidth: 0, maxWidth: geo.size.width / 2)
                            }
                        }.frame(width: geo.size.width)
                    }
                }.frame(minHeight: 0, maxHeight: .infinity)
            }
            .frame(minHeight: 0, maxHeight: geo.size.height)
            .navigationBarTitle("", displayMode: .inline)
        }
        .onDisappear(perform: {
            self.postAvoidedFoods()
            self.userProfileModel.setPossibleAllergies()
        })
    }
    
    func postAvoidedFoods() {
        let requestManager = ApiRequestManagerWithHandling(userProfileModel: self.userProfileModel)
        requestManager.postAvoidableFoods(
            avoidedFoodIds: self.userProfileModel.avoidedFoods.map { $0.id }
        )
    }
    func getColumnsForThisRow(_ row: Int) -> Int {
        //Column count can change for last row
        let foodsCount = self.userProfileModel.avoidableFoods.count
        if row + 1 == getRowCount() {
            return foodsCount % columns == 0 ? columns : foodsCount % columns
        }
        
        return columns
    }
    
    func getRowCount() -> Int {
        let foodsCount = self.userProfileModel.avoidableFoods.count
        let rows = Double(Double(foodsCount) / Double(columns)).rounded(.up)
        return Int(rows)
    }
    
    func getIndex(_ row: Int, _ column: Int) -> Int {
        row * columns + column
    }
}

struct FoodPreferencesView_Previews: PreviewProvider {
    static let mockedModel = UserProfileModel.mock
    
    static var previews: some View {
        VStack {
            FoodPreferencesView()
                .environmentObject(mockedModel)
        }
    }
}
