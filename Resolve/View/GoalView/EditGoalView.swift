//
//  EditGoalView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/26/22.
//

import SwiftUI
import CoreHaptics

struct EditGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirm = false
    @ObservedObject var goal: Goal
    @EnvironmentObject var dataController: DataController
    @State private var engine = try? CHHapticEngine()
    @State private var title: String
    @State private var detail: String
    @State private var color: String
    @State private var remindMe: Bool
    @State private var reminderTime: Date
    @State private var showingNotificationsError = false
    let colorColumns = [GridItem(.adaptive(minimum: 44))]
    
    init(goal: Goal) {
        self.goal = goal
        
        _title = State(wrappedValue: goal.goalTitle)
        _detail = State(wrappedValue: goal.goalDetail)
        _color = State(wrappedValue: goal.goalColor)
        
        if let goalReminderTime = goal.reminderTime {
            _reminderTime = State(wrappedValue: goalReminderTime)
            _remindMe = State(wrappedValue: true)
        } else {
            _reminderTime = State(wrappedValue: Date())
            _remindMe = State(wrappedValue: false)
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Basic settings")) {
                TextField("Goal name", text: $title.onChange(update))
                TextField("Description of this goal", text: $detail.onChange(update))
            }
            
            Section(header: Text("Custom goal color")) {
                LazyVGrid(columns: colorColumns) {
                    ForEach(Goal.colors, id: \.self) { item in
                        colorButton(for: item)
                    }
                }
                .padding(.vertical)
            }
            Section(header: Text("Goal reminders")) {
                Toggle("Show reminders", isOn: $remindMe.animation().onChange(update))
                    .alert("Oops!", isPresented: $showingNotificationsError) {
                        Button("Check Settings", action: showAppSettings)
                        Button("Cancel", role: .cancel, action: {})
                    } message: {
                        Text("There was a problem. Please check you have notifications enabled")
                    }
                
                if remindMe {
                    DatePicker("Reminder time", selection: $reminderTime.onChange(update), displayedComponents: .hourAndMinute)
                }
            }
               
                Section(footer: Text("Closing a goal moves it from the Open to Closed tab; deleting it removes the project completely.")) {
                    Button(goal.closed ? "Reopen this goal" : "Close this goal", action: toggleClosed)
                    Button("Delete this goal") {
                        showingDeleteConfirm.toggle()
                    }
                    .tint(.red)
                }
            
        }
        .navigationTitle("Edit Goal")
        .onDisappear(perform: dataController.save)
        .alert("Delete goal?", isPresented: $showingDeleteConfirm) {
            Button("Ok", role: .cancel) {}
            Button("Delete", role: .destructive) { delete() }
        } message: {
            Text("Are you sure you want to delete this goal? You will also delete all the items it contains.")
        }
    }
    
    private func update() {
        goal.title = title
        goal.detail = detail
        goal.color = color
        
        if remindMe {
            goal.reminderTime = reminderTime
            
            Task {
                do {
                  let success =  try await dataController.addReminders(for: goal)
                    if !success {
                        goal.reminderTime = nil
                        remindMe = false
                        showingNotificationsError = true
                    }
                    
                } catch {
                    print(error)
                }
                
            }
        } else {
            goal.reminderTime = nil
            dataController.removeReminders(for: goal)
        }
    }
    
    private func delete() {
        dataController.delete(goal)
        dismiss()
    }
    
    private func colorButton(for item: String) -> some View {
        ZStack {
            Color(item)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(6)
            if item == color {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .onTapGesture {
            color = item
            update()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(item == color ? [.isButton, .isSelected] : .isButton)
        .accessibilityLabel(LocalizedStringKey(item))
    }
    
    private func toggleClosed() {
        goal.closed.toggle()
        if goal.closed {
            do {
                try engine?.start()
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
                let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
                let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)
                
                // Use that curve to control the haptic strength
                let parameter = CHHapticParameterCurve(
                    parameterID: .hapticIntensityControl,
                    controlPoints: [start, end],
                    relativeTime: 0)
                let event1 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: 0)
                let event2 = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [sharpness, intensity],
                    relativeTime: 0.125,
                    duration: 1)
                let pattern = try CHHapticPattern(events: [event1, event2], parameterCurves: [parameter])
                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
            } catch {
                
            }
        }
    }
    
    func showAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

struct EditGoalView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    static var previews: some View {
        EditGoalView(goal: Goal.example)
            .environmentObject(dataController)
    }
}
