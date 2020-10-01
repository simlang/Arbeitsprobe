//
//  StatisticOverviewView.swift
//  sporthealth
//
//  Created by Borchers, Alexander on 27.11.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import SwiftUI
import HealthKit

struct StatisticOverviewView: View {
    @EnvironmentObject private var activityModel: ActivityModel
    
    @State private var showAllActivities: Bool = false
    @State private var showActivityText: String = "Alle anzeigen"
    @State private var hasHeartRateSamples = false
    @State private var maxHeartRate = "-"
    @State private var heartRateAvg = "-"
    @State private var heartRates: [Double] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(activityModel.oldActivities.isEmpty
                ? "Sobald du eine Aktivität absolvierst, erhältst du hier eine Statistik dazu 📈"
                : "Letzte Aktivität")
                .font(.system(size: 22, weight: .medium))
                .fixedSize(horizontal: false, vertical: true)
            if !activityModel.oldActivities.isEmpty {
                VStack(alignment: .leading) {
                    LastActivityComponentView(systemNameImage: "paperplane",
                                              description: "Akitivität",
                                              value: activityModel.oldActivities.last?.emoji ?? "",
                                              valueDescription: activityModel.oldActivities.last?.title ?? "Kein Titel",
                                              headerColor: .primary,
                                              hasDetails: false)
                    LastActivityComponentView(systemNameImage: "timer",
                                              description: "Dauer",
                                              value: "\(Int((activityModel.oldActivities.last?.duration ?? 0) / 60))",
                                              valueDescription: "min",
                                              headerColor: .pink,
                                              hasDetails: false)
                    if hasHeartRateSamples {
                        NavigationLink(destination: DetailedHeartRateView(heartRates: heartRates, heartRateAvg: heartRateAvg)) {
                            LastActivityComponentView(systemNameImage: "waveform.path.ecg",
                                                      description: "Durchschnittlicher Puls",
                                                      value: heartRateAvg,
                                                      valueDescription: "bpm",
                                                      headerColor: .purple,
                                                      hasDetails: true)
                        }
                        LastActivityComponentView(systemNameImage: "heart",
                                                  description: "Höchstwert",
                                                  value: maxHeartRate,
                                                  valueDescription: "bpm",
                                                  headerColor: .red,
                                                  hasDetails: false)
//                        LastActivityComponentView(systemNameImage: "flame",
//                                                  description: "Verbrannte Kalorien",
//                                                  value: "873",
//                                                  valueDescription: "kcal",
//                                                  headerColor: .orange,
//                                                  hasDetails: false)
                    }
                }
            }
        }.onAppear(perform: getHighestHeartRate)
    }
    
    func getHighestHeartRate() {
        if UIDevice.current.userInterfaceIdiom != .phone {
            print("Device is not an iPhone")
            return
        }
        
        if HKManager.noPermission {
            print("No Permission for HealthKit")
            return
        }
        
        let healthStore = HKManager.healthStore
        
        healthStore.requestAuthorization(toShare: HKManager.allTypes, read: HKManager.allTypes) { success, _ in
            if success {
                //print(success.description)
                let heartRate = HKSampleType.quantityType(forIdentifier: .heartRate)!
                
                guard let lastActivity = self.activityModel.oldActivities.last else {
                    return
                }
                print("LastActivity: \(lastActivity.startDate) till \(lastActivity.endDate)")
                let predicate = HKQuery.predicateForSamples(withStart: lastActivity.startDate, end: lastActivity.endDate, options: .strictEndDate)
                let heartRateQuery = HKSampleQuery(sampleType: heartRate,
                                                   predicate: predicate,
                                                   limit: HKObjectQueryNoLimit,
                                                   sortDescriptors: nil) { _, results, error in
                                                    guard error == nil, let samples = results as? [HKQuantitySample] else {
                                                        print("Sth went wrong \(error.debugDescription)")
                                                        return
                                                    }
                                                    
                                                    //print("Samples description: " + samples.description)
                                                    
                                                    if samples.isEmpty {
                                                        self.hasHeartRateSamples = false
                                                        return
                                                    } else {
                                                        self.hasHeartRateSamples = true
                                                    }
                                                    
                                                    self.heartRates = []
                                                    var heartRateSum: Double = 0.0
                                                    
                                                    DispatchQueue.main.async {
                                                        for sample in samples {
                                                            let value = sample.quantity.doubleValue(for: .init(from: "count/min"))
                                                            self.heartRates.append(value)
                                                            heartRateSum += value
                                                        }
                                                        self.maxHeartRate = String(Int(self.heartRates.max()!))
                                                        self.heartRateAvg = String(Int(heartRateSum / Double(self.heartRates.count)))
                                                    }
                }
                healthStore.execute(heartRateQuery)
            }
        }
    }
}

struct StatisticOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .edgesIgnoringSafeArea(.all)
            StatisticOverviewView()
                .environmentObject(ActivityModel())
        }
    }
}
