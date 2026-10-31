import ActivityKit
import Foundation

struct TournexTimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var eventName: String
        var status: String
        var deadline: Date?
        var pausedSeconds: Int
    }
    var store: String
    var tournamentID: String
}
