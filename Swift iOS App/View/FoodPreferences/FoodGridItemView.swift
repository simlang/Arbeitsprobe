//
//  FoodRow.swift
//  sporthealth
//
//  Created by Borchers, Alexander on 25.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI
import URLImage

struct FoodGridItemView: View {
    @EnvironmentObject private var model: UserProfileModel
    @State var isAvoided: Bool = false
    
    var food: Food
    
    var body: some View {
        VStack {
            VStack(spacing: 2) {
                Text(self.food.title)
                    .font(Font.system(size: 20, weight: .bold))
                Button(action: self.setAvoidedFood) {
                    ZStack(alignment: .topTrailing) {
                        URLImage(food.imageUrl,
                                 placeholder: { _ in
                                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                                    .padding(100)
                                 }) { proxy in
                                        proxy.image
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .overlay(
                                                Rectangle() .foregroundColor(.red).opacity(self.isAvoided ? 0.5 : 0)
                                        )
                                        .cornerRadius(15)
                        }
                    }
                }
            }
        }
    }

    func setAvoidedFood() {
        isAvoided.toggle()
        if isAvoided {
            model.addAvoidedFood(food)
        } else {
            model.removeAvoidedFood(food.id)
        }
    }
}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct FoodRow_Previews: PreviewProvider {
    static let mockedModel = UserProfileModel.mock
    
    static var previews: some View {
        FoodGridItemView(food: Food(id: UUID(), title: "Pizza", imageUrl: URL(string: "https://shiftytum.s3.eu-central-1.amazonaws.com/134472796915784332861")!, foodSizes: [], possibleAllergies: []))
            .environmentObject(mockedModel)
    }
}
