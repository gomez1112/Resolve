//
//  AwardsView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/28/22.
//

import SwiftUI

struct AwardsView: View {
    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false
    @EnvironmentObject private var dataController: DataController
    static let tag: String? = "Awards"
    private let columns = [GridItem(.adaptive(minimum: 100, maximum: 100))]
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            selectedAward = award
                            showingAwardDetails = true
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundColor(dataController.hasEarned(award: award) ? Color(award.color) : Color.secondary.opacity(0.5))
                        }
                    }
                }
            }
            .navigationTitle("Awards")
        }
        .alert(isPresented: $showingAwardDetails) {
            if dataController.hasEarned(award: selectedAward) {
                return .init(title: Text("Unlocked: \(selectedAward.name)"), message: Text(selectedAward.description), dismissButton: .default(Text("OK")))
            } else {
                return .init(title: Text("Locked"), message: Text(selectedAward.description), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct AwardsView_Previews: PreviewProvider {
    static let dataController = DataController()
    static var previews: some View {
        AwardsView()
            .environmentObject(dataController)
    }
}
