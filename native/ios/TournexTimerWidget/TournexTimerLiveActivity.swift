import ActivityKit
import WidgetKit
import SwiftUI

struct TournexTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TournexTimerAttributes.self) { context in
            HStack(spacing: 14) {
                VStack(alignment: .leading) {
                    Text("TOURNEX · ROUND TIMER").font(.caption).bold()
                    Text(context.state.eventName).font(.subheadline).lineLimit(1)
                    Text(context.state.status.capitalized).font(.caption2)
                }
                Spacer()
                countdown(context.state).font(.system(size: 34, weight: .bold, design: .rounded))
            }
            .padding()
            .activityBackgroundTint(Color(red: 0.04, green: 0.21, blue: 0.15))
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("TOURNEX").font(.caption).bold()
                }
                DynamicIslandExpandedRegion(.trailing) {
                    countdown(context.state).font(.title2).bold()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.eventName).lineLimit(1)
                }
            } compactLeading: {
                Image(systemName: "timer")
            } compactTrailing: {
                countdown(context.state).font(.caption2).monospacedDigit()
            } minimal: {
                Image(systemName: "timer")
            }
        }
    }

    @ViewBuilder private func countdown(_ state: TournexTimerAttributes.ContentState) -> some View {
        if let deadline = state.deadline, state.status == "running" {
            Text(timerInterval: Date()...max(deadline, Date()), countsDown: true)
                .monospacedDigit()
        } else {
            Text(String(format: "%02d:%02d", max(0, state.pausedSeconds) / 60,
                        max(0, state.pausedSeconds) % 60))
                .monospacedDigit()
        }
    }
}

@main
struct TournexTimerWidgetBundle: WidgetBundle {
    var body: some Widget { TournexTimerLiveActivity() }
}
