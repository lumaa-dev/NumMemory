//Made by Lumaa

import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var canPlay: Bool = true
    @State private var hourPlayable: String = ""
    @State private var string: String? = UserDefaults.standard.string(forKey: "memory")
    @State private var entered: String = ""
    @State private var correct: Bool = false
    
    private let dateFormat: String = "dd/MM/yyyy HH:mm"
    
    var body: some View {
        if correct == true {
            VStack {
                Label("Correct !", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.largeTitle.bold())
                Text("À demain, pour une nouvelle tentative !")
            }
        } else {
            if string != nil {
                VStack {
                    Text("Devinez votre numéro :")
                    
                    if canPlay {
                        TextField(text: $entered, prompt: Text("0123456789"), label: { EmptyView() })
                            .textFieldStyle(.roundedBorder)
                            .padding()
                            .keyboardType(.numberPad)
                            .autocorrectionDisabled()
                            .disabled(!canPlay)
                    } else {
                        Text("Vous pourrez jouer qu'à partir de \(hourPlayable)")
                    }
                    
                    Button {
                        if string != entered.trimmingCharacters(in: .whitespacesAndNewlines) {
                            entered = ""
                        } else {
                            correct.toggle()
                            notifPlanner()
                            UNUserNotificationCenter.current().setBadgeCount(0)
                        }
                    } label: {
                        Text("Essayer")
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .disabled(entered.isEmpty)
                    
                    Button {
                        allowsPlaying()
                    } label: {
                        Text("Rafraichir")
                    }
                    .padding(.vertical)
                }
                .padding()
                .onAppear() {
                    allowsPlaying()
                }
            } else {
                VStack {
                    Spacer()
                    
                    Text("Entrez des numéros quelconques :")
                    TextField(text: $entered, prompt: Text("0123456789"), label: { EmptyView() })
                        .textFieldStyle(.roundedBorder)
                        .padding()
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                    
                    Spacer()
                    
                    Button {
                        UserDefaults.standard.setValue(entered.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "memory")
                        correct.toggle()
                        notifPlanner()
                    } label: {
                        Text("Sauvegarder")
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                }
                .onAppear {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
                        if success {
                            print("Notifications accepted")
                        } else if let error = error {
                            print(error)
                        }
                    }
                }
            }
        }
    }
    
    private func notifPlanner() {
        let content = UNMutableNotificationContent()
        content.title = "MemoryNumero"
        content.body = "Tu peux maintenant deviner ton numéro"
        content.badge = 1
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
        
        let comp = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: tomorrow)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: false)
        let request = UNNotificationRequest(identifier: "game", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
        let date = Calendar.current.date(from: comp) ?? .now
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        let datePlay = formatter.string(from: date)
        
        UserDefaults.standard.setValue(datePlay, forKey: "datePlay")
        
        print("Notif tomorrow at exact time")
    }
    
    private func allowsPlaying() {
        let saved = UserDefaults.standard.string(forKey: "datePlay") ?? "???"

        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        if let datePlay = formatter.date(from: saved) {
            canPlay = datePlay.timeIntervalSinceNow <= 0.0
            
            if !canPlay {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                hourPlayable = formatter.string(from: datePlay)
            }
        }
    }
}

#Preview {
    ContentView()
}
