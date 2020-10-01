//
//  MultipleSelectRowView.swift
//  sporthealth
//
//  Created by Ennemoser, Franz Josef on 28.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct MultipleSelectRowView: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark").foregroundColor(.blue)
                }
            }
        }.foregroundColor(Color.black)
    }
}

struct MultipleSelectRowView_Previews: PreviewProvider {
    static var previews: some View {
        MultipleSelectRowView(title: "test", isSelected: true, action: {})
    }
}
