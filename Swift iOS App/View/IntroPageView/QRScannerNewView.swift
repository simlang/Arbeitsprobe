//
//  QRScannerNewView.swift
//  sporthealth
//
//  Created by Franz Josef Ennemoser on 17.01.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI
import CodeScanner
import Combine
import Squid

struct QRScannerNewView: View {
    @Binding var currentPage: Int
    @State private var isShowingScanner = false
    @EnvironmentObject var userDefaultsPublisher: UserDefaultsPublisher
    @EnvironmentObject var userProfileModel: UserProfileModel
    @EnvironmentObject var surveyModel: SurveyModel
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertText = ""
    @State private var cancellableSet: Set<AnyCancellable> = []
    private let requestManager = ApiRequestManager()
    
    private let simulatorApiKey =
    "za7Hcqwo2gUADMUnqDVjasMS4YvEMvk5GrCvECDP8NB864AyR7WgINH4rn2kHU2O2wWaWGbjzKBUrGPt9KBkuhd7NZgYzHq0suQSE88Thw8RsSBUWYfmcvwJXh7QMPwD"
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 25)
            Text("Anmeldung")
                .modifier(TextHeadlineModifier())
            Spacer()
                .frame(height: 25)
            Text("Um dich anzumelden, musst du nun deinen QR Code scannen.")
                .modifier(IntroTextModifier())
            Text("Gib uns dafür bitte Zugriff auf deine Kamera.")
                .modifier(IntroTextModifier())
            Image("placeholder3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: .infinity)
            Spacer()
            Button(action: {
                self.isShowingScanner = true
            }) {
                ContinueButtonView(text: "Scannen", color: Color("primaryHeadlineColor"))
                    .padding(.horizontal)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle),
                      message: Text(alertText),
                      dismissButton: .default(Text("Okay"), action: {}))
            }
        }.sheet(isPresented: $isShowingScanner) {
            CodeScannerView(
                codeTypes: [.qr],
                simulatedData: self.simulatorApiKey,
                completion: self.handleCameraScan)
        }
    }
    func handleCameraScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
        
        switch result {
        case .success(let scannedString):
            self.userDefaultsPublisher.apiKey = scannedString
            
            if !self.requestManager.isConnectedToInternet() {
                self.showAlertNoInternet()
                break
            }
            
            //Request avoidable foods to check api key & get the foods at the same time
            self.requestManager.getAvoidableFoods()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        switch error {
                        case .requestFailed(let (statusCode, _)):
                            if statusCode == 404 {
                                self.showAlertNotFound()
                            }
                        default:
                            print(error)
                            self.showAlertUnknownError()
                        }
                    case .finished:
                        break
                    }
                }) { result in
                    DispatchQueue.main.async {
                        self.userProfileModel.setAvoidableFoods(result.data)
                        print("Set avoidablefoods from api call in the model")
                        self.currentPage += 1
                    }
                }
                .store(in: &cancellableSet)
            
            
            let requestManagerWithHandling = ApiRequestManagerWithHandling(surveyModel: self.surveyModel,
                                                                           userDefaultsPublisher: self.userDefaultsPublisher)
            requestManagerWithHandling.postDeviceId()
            requestManagerWithHandling.getLatestSurveys()
            
        case .failure(let error):
            print("Scanning failed because of: \(error)")
        }
    }
    
    private func showAlertNoInternet() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showAlert = true
            self.alertTitle = "Keine Internetverbindung"
            self.alertText = "Bitte stellen Sie sicher, dass das Gerät mit dem Internet verbunden ist und probieren sie es erneut."
        }
    }
    private func showAlertNotFound() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showAlert = true
            self.alertTitle = "Probleme mit dem QR Code"
            self.alertText = "Bitte stellen Sie sicher, dass sie den richtigen QR Code scannen. Sie erhalten ihn von einem Administrator."
        }
    }
    private func showAlertUnknownError() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showAlert = true
            self.alertTitle = "Unbekannter Serverfehler"
            self.alertText = "Bitte probieren Sie es später noch einmal oder kontaktieren Sie einen Administrator."
        }
    }
}

struct QRScannerNewView_Previews: PreviewProvider {
    static var previews: some View {
        QRScannerNewView(currentPage: .constant(0))
    }
}
