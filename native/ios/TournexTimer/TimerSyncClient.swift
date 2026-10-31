import Foundation

struct TournamentInfo {
    let id: String
    let eventName: String
    let timer: RoundTimer
}

struct RoundTimer: Decodable {
    let status: String
    let remaining_seconds: Double?
    let started_at: String?

    func activityState(eventName: String) -> TournexTimerAttributes.ContentState {
        let remaining = remaining_seconds ?? 0
        let start = started_at.flatMap { ISO8601DateFormatter().date(from: $0) }
        let end = (start ?? Date()).addingTimeInterval(remaining)
        return .init(eventName: eventName, status: status,
                     deadline: status == "running" ? end : nil,
                     pausedSeconds: Int(remaining))
    }
}

private struct TournamentRow: Decodable {
    let id: String
    let event_name: String?
}

struct TimerSyncClient {
    private let base = URL(string: "https://njulnumhkxvtdfrjoigx.supabase.co")!
    private let key = "sb_publishable_31ke9sSB-21M8MXDWZm1lA_p_sYct8Z"

    func fetch(store: String) async throws -> TournamentInfo {
        var components = URLComponents(url: base.appending(path: "rest/v1/tournaments"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            .init(name: "select", value: "id,event_name"),
            .init(name: "store_name", value: "eq.\(store)"),
            .init(name: "public_pairings_enabled", value: "eq.true"),
            .init(name: "order", value: "created_at.desc"),
            .init(name: "limit", value: "1")
        ]
        var request = URLRequest(url: components.url!)
        request.setValue(key, forHTTPHeaderField: "apikey")
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response)
        guard let tournament = try JSONDecoder().decode([TournamentRow].self, from: data).first else {
            throw URLError(.resourceUnavailable)
        }

        var timerRequest = URLRequest(url: base.appending(path: "rest/v1/rpc/public_round_timer_v23"))
        timerRequest.httpMethod = "POST"
        timerRequest.setValue(key, forHTTPHeaderField: "apikey")
        timerRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        timerRequest.httpBody = try JSONSerialization.data(withJSONObject: ["p_tournament_id": tournament.id])
        let (timerData, timerResponse) = try await URLSession.shared.data(for: timerRequest)
        try validate(timerResponse)
        let timer = try JSONDecoder().decode(RoundTimer.self, from: timerData)
        return TournamentInfo(id: tournament.id, eventName: tournament.event_name ?? "Tournament", timer: timer)
    }

    private func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
