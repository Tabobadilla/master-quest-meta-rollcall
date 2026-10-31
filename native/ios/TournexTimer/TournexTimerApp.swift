import SwiftUI
import ActivityKit

@main
struct TournexTimerApp: App {
    var body: some Scene {
        WindowGroup { TimerHomeView() }
    }
}

struct TimerHomeView: View {
    @State private var store = ""
    @State private var message = "Enter your Tournex store name."
    @State private var running = false
    private let client = TimerSyncClient()

    var body: some View {
        NavigationStack {
            Form {
                Section("Tournament store") {
                    TextField("Store name", text: $store)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                    Button("Connect and show Live Activity") {
                        Task { await connect() }
                    }
                    .disabled(store.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                Section("Status") { Text(message) }
                Section {
                    Text("The Live Activity uses the same timer as Tournex. Background pause, reset, and tournament changes require APNs push updates from the server; this starter refreshes while the app is open.")
                        .font(.footnote)
                }
            }
            .navigationTitle("Tournex Timer")
        }
        .task {
            while !Task.isCancelled {
                if running { await refresh() }
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }

    @MainActor private func connect() async {
        running = true
        await refresh()
    }

    @MainActor private func refresh() async {
        do {
            let info = try await client.fetch(store: store)
            message = "\(info.eventName) · \(info.timer.status)"
            let attributes = TournexTimerAttributes(store: store, tournamentID: info.id)
            let content = ActivityContent(state: info.timer.activityState(eventName: info.eventName),
                                          staleDate: Date().addingTimeInterval(20))
            if let activity = Activity<TournexTimerAttributes>.activities.first(where: {
                $0.attributes.tournamentID == info.id
            }) {
                await activity.update(content)
            } else if ActivityAuthorizationInfo().areActivitiesEnabled {
                _ = try Activity.request(attributes: attributes, content: content, pushType: .token)
            } else {
                message = "Enable Live Activities for Tournex in iPhone Settings."
            }
        } catch {
            message = "Unable to synchronize: \(error.localizedDescription)"
        }
    }
}
