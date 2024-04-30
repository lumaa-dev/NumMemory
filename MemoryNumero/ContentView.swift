//Made by Lumaa

import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var allowsNotif: Bool = false
    
    @State private var canPlay: Bool = true
    @State private var hourPlayable: Date = .now
    
    @State private var string: String? = UserDefaults.standard.string(forKey: "memory")
    @State private var entered: String = ""
    
    @State private var correct: Bool = false
    @State private var incorrect: Bool = false
    
    @State private var toolbarOpen: Bool = false
    @State private var tappedRefresh: Bool = false
    @State private var enabledNotif: Bool = true
    @State private var delConfirm: Bool = false
    
    private let dateFormat: String = "dd/MM/yyyy HH:mm"
    
    var body: some View {
        if correct == true {
            VStack {
                Label("Correct !", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.largeTitle.bold())
                Text("À demain, pour une nouvelle tentative !")
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10.0))
            .transition(.move(edge: .top).combined(with: .opacity))
        } else {
            if string != nil {
                VStack {
                    Text("Devinez le numéro !")
                        .font(.title.bold())
                        .padding(.top)
                    
                    if incorrect {
                        Label("Le numéro est incorrect", systemImage: "xmark.circle.fill")
                            .foregroundStyle(Color.red)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    Spacer()
                    
                    if canPlay {
                        TextField(text: $entered, prompt: Text("0123456789"), label: { EmptyView() })
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 25.0))
                            .padding()
                            .keyboardType(.numberPad)
                            .autocorrectionDisabled()
                            .disabled(!canPlay)
                            .padding(.vertical)
                        
                        Button {
                            if string != entered.trimmingCharacters(in: .whitespacesAndNewlines) {
                                withAnimation(.spring.speed(1.7)) {
                                    entered = ""
                                    incorrect = true
                                }
                            } else {
                                withAnimation(.spring.speed(1.7)) {
                                    correct.toggle()
                                }
                                notifPlanner()
                                UNUserNotificationCenter.current().setBadgeCount(0)
                            }
                        } label: {
                            Text("Essayer")
                                .font(.title3.bold())
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                        .disabled(entered.isEmpty)
                    } else {
                        Text("Vous pourrez jouer dans...")
                        Text(hourPlayable, style: .timer)
                            .font(.largeTitle.bold().monospacedDigit())
                            .contentTransition(.numericText(countsDown: true))
                            .transaction { transaction in
                                transaction.animation = .default.speed(0.6)
                            }
                    }
                    
                    Spacer()
                    
                    if toolbarOpen {
                        HStack(spacing: 10) {
                            Button {
                                withAnimation(.bouncy) {
                                    toolbarOpen.toggle()
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .imageScale(.large)
                            }
                            
                            Divider()
                                .frame(height: 25)
                            
                            if #available(iOS 17.0, *) {
                                Button {
                                    allowsPlaying()
                                } label: {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .imageScale(.large)
                                }
                                .disabled(canPlay)
                                .symbolEffect(.bounce.up.byLayer, value: tappedRefresh)
                            } else {
                                Button {
                                    allowsPlaying()
                                } label: {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .imageScale(.large)
                                }
                                .disabled(canPlay)
                            }
                            
                            Divider()
                                .frame(height: 25)
                            
                            if #available(iOS 17.0, *) {
                                Button {
                                    withAnimation {
                                        enabledNotif.toggle()
                                    }
                                    toggledNotif()
                                } label: {
                                    Image(systemName: enabledNotif ? "bell.badge" : "bell.badge.slash")
                                        .imageScale(.large)
                                }
                                .contentTransition(.symbolEffect(.replace.downUp.wholeSymbol))
                                .disabled(!allowsNotif)
                            } else {
                                Button {
                                    withAnimation {
                                        enabledNotif.toggle()
                                    }
                                    toggledNotif()
                                } label: {
                                    Image(systemName: enabledNotif ? "bell.badge" : "bell.slash.badge")
                                        .imageScale(.large)
                                }
                                .transition(.opacity.combined(with: .scale))
                                .disabled(!allowsNotif)
                            }
                                
                            
                            Divider()
                                .frame(height: 25)
                            
                            if #available(iOS 17.0, *) {
                                Button {
                                    delConfirm.toggle()
                                } label: {
                                    Image(systemName: "trash")
                                        .imageScale(.large)
                                }
                                .tint(Color.red)
                                .symbolEffect(.bounce.up.byLayer, value: delConfirm)
                            } else {
                                Button {
                                    delConfirm.toggle()
                                } label: {
                                    Image(systemName: "trash")
                                        .imageScale(.large)
                                }
                                .tint(Color.red)
                            }
                        }
                        .confirmationDialog("Voulez-vous vraiment supprimer le numéro ?", isPresented: $delConfirm, titleVisibility: .visible) {
                            Button(role: .cancel) {
                                delConfirm.toggle()
                            } label: {
                                Text("Annuler")
                            }
                            
                            Button(role: .destructive) {
                                UserDefaults.standard.removeObject(forKey: "memory")
                                UserDefaults.standard.removeObject(forKey: "datePlay")
                                canPlay = true
                                string = nil
                                entered = ""
                                correct = false
                                incorrect = false
                                
                                delConfirm.toggle()
                            } label: {
                                Text("Supprimer")
                            }
                        }
                        .transition(.move(edge: .leading).combined(with: .opacity))
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        ZStack(alignment: .leading) {
                            Button {
                                reqNotifs()
                                withAnimation(.bouncy) {
                                    toolbarOpen.toggle()
                                }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .padding(.horizontal)
                                    .padding(.vertical, 10)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .frame(width: 300, height: 50, alignment: .leading)
                    }
                }
                .padding()
                .onAppear() {
                    allowsPlaying()
                }
            } else {
                VStack {
                    Text("Enregistrez un numéro")
                        .font(.title.bold())
                        .padding(.top)
                    Text("Les numéros entrés restent sur votre appareil, et ne le quitte jamais.")
                        .padding(.horizontal)
                        .foregroundStyle(.gray)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                
                    TextField(text: $entered, prompt: Text("0123456789"), label: { EmptyView() })
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                        .padding()
                        .keyboardType(.numberPad)
                        .autocorrectionDisabled()
                        .padding(.vertical)
                    
                    Button {
                        reqNotifs()
                        
                        UserDefaults.standard.setValue(entered.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "memory")
                        correct.toggle()
                        notifPlanner()
                        string = ""
                    } label: {
                        Text("Enregistrer")
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .disabled(entered.isEmpty)
                    
                    Spacer()
                    
                    ZStack(alignment: .leading) {
                        Button {
                            withAnimation(.bouncy) {
                                toolbarOpen.toggle()
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .disabled(true)
                    }
                    .frame(width: 300, height: 50, alignment: .leading)
                }
            }
        }
    }
    
    private func reqNotifs() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if success {
                print("Notifications accepted")
                allowsNotif = true
            } else if let error = error {
                print(error)
                allowsNotif = false
            }
        }
    }
    
    private func toggledNotif() {
        if enabledNotif && allowsNotif {
            notifPlanner(toggled: true)
        } else {
            enabledNotif = false
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["game"])
            print("Removed \"game\" notifications")
        }
    }
    
    private func notifPlanner(toggled: Bool = false) {
        guard allowsNotif && enabledNotif else {
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
            let comp = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: tomorrow)
            
            let date = Calendar.current.date(from: comp) ?? .now
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            let datePlay = formatter.string(from: date)
            
            UserDefaults.standard.setValue(datePlay, forKey: "datePlay")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "NumMemory"
        content.body = String(localized: "Tu peux maintenant deviner le numéro")
        content.badge = 1
        
        if !toggled {
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
        } else {
            let saved = UserDefaults.standard.string(forKey: "datePlay") ?? "???"
            
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            if let datePlay = formatter.date(from: saved) {
                guard datePlay.timeIntervalSinceNow > 0.0 else { return } // can play
                
                let comp = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: datePlay)
                let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: false)
                let request = UNNotificationRequest(identifier: "game", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
                
                print("Recovered notification from datePlay")
            }
        }
    }
    
    private func allowsPlaying() {
        withAnimation {
            tappedRefresh.toggle()
        }
        
        let saved = UserDefaults.standard.string(forKey: "datePlay") ?? "???"

        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        if let datePlay = formatter.date(from: saved) {
            withAnimation(.spring.speed(1.7)) {
                canPlay = datePlay.timeIntervalSinceNow <= 0.0
            }
            
            if !canPlay {
                hourPlayable = datePlay
            }
        }
    }
}

#Preview {
    ContentView()
//        .onAppear {
//            UserDefaults.standard.setValue("00:00", forKey: "datePlay")
//        }
//        .onDisappear {
//            UserDefaults.standard.setValue("00:00", forKey: "datePlay")
//        }
}
