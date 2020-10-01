//
//  MultipleSelectPicker.swift
//  sporthealth
//
//  Created by Ennemoser, Franz Josef on 28.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI

struct MultipleSelectPicker: View {
    @State private var selections = [Day]()

    @ObservedObject var daysToRepeat: DaysToRepeat
    
    init(_ daysToRepeat: DaysToRepeat) {
        self.daysToRepeat = daysToRepeat
    }

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Wann wirst du die Aktivität wiederholen?")) {
                    ForEach(Day.allCases) { item in
                        MultipleSelectRowView(title: item.fullString, isSelected: self.selections.contains(item)) {
                            if self.selections.contains(item) {
                                self.selections.removeAll(where: { $0 == item })
                            } else {
                                self.selections.append(item)
                            }
                        }
                    }
                }
            }
            .onAppear(perform: { self.selections = self.daysToRepeat.days })
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Tage", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    self.daysToRepeat.days = self.selections
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("OK")
                }
            )
        }
    }
}

struct MultipleSelectPicker_Previews: PreviewProvider {
    static var previews: some View {
        MultipleSelectPicker(DaysToRepeat())
    }
}
