# Tournex iOS Live Activity integration — starter

This folder contains Swift source files, **not yet a compiled or signed iPhone app**.

## Build requirements
- Mac with a current version of Xcode supporting ActivityKit and an iOS 16.2+ deployment target.
- An iOS app target named `TournexTimer` and a Widget Extension target named `TournexTimerWidget`.
- Add `TournexTimerApp.swift` and `TimerSyncClient.swift` to the app target.
- Add `TournexTimerLiveActivity.swift` to the widget target.
- Add `Shared/TournexTimerAttributes.swift` to **both** targets.
- Set `NSSupportsLiveActivities = YES` in the iOS app target's Info.plist.
- Enable Push Notifications capability for remote Live Activity updates. A signed build and APNs configuration are needed to deliver background updates.

## Current behavior
- App looks up the latest public tournament for a given store and reads the existing `public_round_timer_v23` RPC.
- The app starts or updates a Live Activity while it is open and refreshes every 5 seconds.
- The Lock Screen and Dynamic Island use a system-rendered countdown to the calculated deadline.
- This starter is **not** an end-to-end remote Live Activity solution: timer pause/resume/reset while the app is backgrounded requires a secure server to register ActivityKit push tokens and send APNs Live Activity updates.
- The starter assumes `public_round_timer_v23` returns the timer fields `status`, `remaining_seconds`, and `started_at`. Validate the actual RPC payload and the device's clock before production use.
- No Professor permissions or existing tournament records are modified.

## Next work
1. Create and sign the Xcode project and test on a physical iPhone.
2. Register ActivityKit push tokens securely, associated with a tournament and device.
3. Build a server-side APNs sender with Apple credentials stored only in server secrets, never in the website or repository.
4. Trigger updates on timer start, pause, resume, reset, and tournament changes.
5. Add Android foreground service and Windows/macOS native companion apps using the same timer state.
