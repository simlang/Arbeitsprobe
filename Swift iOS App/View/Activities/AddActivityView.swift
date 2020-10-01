//
//  AddActivityView.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 27.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import Combine
import SwiftUI

struct AddActivityView: View {
    @EnvironmentObject private var model: ActivityModel
    @EnvironmentObject private var surveyModel: SurveyModel
    @Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject var daysToRepeat = DaysToRepeat()
    
    @State var id: Activity.ID?
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var title: String = ""
    @State private var emoji: String = ""
    @State private var remind: Bool = false
    
    @State private var showAlert = false
    @State private var showDaysSheet = false
    
    @State private var toDelete = false
    
    private var recurringDaysString: String {
        var combinedString: String = ""
        for day in daysToRepeat.days.sorted(by: <) {
            if !combinedString.isEmpty {
                combinedString += ", "
            }
            combinedString += day.abbreviation
        }
        return combinedString
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Start")) {
                    DatePicker("",
                               selection: $startDate,
                               in: Date()...)
                        .labelsHidden()
                        .onTapGesture {
                            self.endEditing()
                        }
                }
                Section(header: Text("Ende")) {
                    DatePicker("",
                               selection: $endDate,
                               in: startDate.addingTimeInterval(20 * 60)...)
                        .labelsHidden()
                        .onTapGesture {
                            self.endEditing()
                        }
                }
                Section(header: Text("Aktivität")) {
                    if id != nil || !emoji.isEmpty {
                        Text(emoji)
                    }
                    TextField("Um welche Aktivität handelt es sich?", text: $title, onEditingChanged: { _ in
                        if !self.title.isEmpty {
                            self.fillEmojiForTitle()
                        } else {
                            self.emoji = ""
                        }
                    })
                    
                    Toggle("Erinnern", isOn: $remind)
//                    Button(action: { self.showDaysSheet.toggle() }) {
//                        HStack {
//                            Text("Wiederholen").foregroundColor(Color.black)
//                            Spacer()
//                            Text("\(recurringDaysString)")
//                                .foregroundColor(Color(UIColor.systemGray))
//                                .font(.body)
//                            Image(systemName: "chevron.right")
//                                .foregroundColor(Color(UIColor.systemGray4))
//                                .font(Font.body.weight(.medium))
//                        }
//                    }
//                    .sheet(isPresented: $showDaysSheet) {
//                        MultipleSelectPicker(self.daysToRepeat)
//                    }
                }
                Section {
                    HStack {
                        Spacer()
                        Button(action: delete) {
                            Text("Diese Aktivität löschen")
                        }.disabled(id == nil)
                        Spacer()
                    }
                }
            }
            .onAppear(perform: updateStates)
            .navigationBarTitle(id == nil ? "Aktivität hinzufügen" : "Aktivität bearbeiten", displayMode: .inline)
            .navigationBarItems(trailing: id == nil ? saveButton : nil)
            .onDisappear(perform: {
                if !self.toDelete {
                    if !self.title.isEmpty {
                        self.save()
                    }
                }
            })
        }.background(Color(UIColor.systemGray6))
         .modifier(AdaptsToSoftwareKeyboard())
    }
    private var saveButton: some View {
        Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
            Text("Speichern").bold()
        }.disabled(title.isEmpty)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Du hast bereits eine Aktivität zu dieser Uhrzeit mit dem Titel \(title)"),
                      message: Text("Wähle bitte eine andere Uhrzeit oder bearbeite die existierende Aktivität."),
                      dismissButton: .default(Text("Alles klar!")))
            }
    }
    
    private func fillTitleForEmoji() {
        sportTitles.forEach { sport in
            if sport[1] == emoji {
                title = sport[0]
                return
            }
        }
    }
    
    private func fillEmojiForTitle() {
        var takeDefualtEmoji = true
        sportTitles.forEach { sport in
            if title.lowercased().contains(sport[0].lowercased()) {
                emoji = sport[1]
                takeDefualtEmoji = false
            }
        }
        // default if the title doesnt match to one of our sportstitle
        if takeDefualtEmoji {
            emoji = "🏃‍♂️"
        }
    }
    
    private func updateStates() {
        guard let activity = model.getActivity(by: id) else {
            self.id = nil
            self.emoji = ""
            self.title = ""
            self.startDate = Date().roundToNextFullHour() ?? Date()
            self.endDate = Date(timeInterval: 3600, since: self.startDate)
            self.remind = false
            daysToRepeat.days = []
            return
        }
        // Fill attributes from existing activity
        self.emoji = activity.emoji
        self.title = activity.title
        self.startDate = activity.startDate
        self.endDate = activity.endDate
        daysToRepeat.days = activity.days
        self.remind = false
        return
    }
    private func delete() {
        if let id = self.id {
            model.delete(activity: id)
        }
        //updateStates()
        toDelete = true
        self.presentationMode.wrappedValue.dismiss()
    }
    /// Save the transaction
    private func save() {
        if isActivityAlreadyStored() && self.id == nil {
            showAlert = true
            return
        }
        let activity = Activity(id: self.id ?? UUID(),
                                emoji: self.emoji,
                                title: self.title,
                                date: self.startDate,
                                duration: self.endDate.timeIntervalSince(self.startDate),
                                days: self.daysToRepeat.days)
        self.model.save(activity)
        self.surveyModel.queueUnqueuedSurveys(firstActivity: self.model.activities.first(where: { $0.startDate > Date() }))
        //updateStates()
        if self.presentationMode.wrappedValue.isPresented {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func isActivityAlreadyStored() -> Bool {
        model.activities.contains(where: { $0.id == self.id })
    }
}

struct AddActivityView_Previews: PreviewProvider {
    static var mockedModel = ActivityModel.mock
    
    static var previews: some View {
        NavigationView {
            AddActivityView().environmentObject(mockedModel)
        }
    }
}

extension AddActivityView {
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
