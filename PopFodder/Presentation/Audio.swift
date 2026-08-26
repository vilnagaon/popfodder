import AVFoundation

enum SFX {
    private static var players: [String: AVAudioPlayer] = [:]
    private static var armed = false

    static func boot() {
        guard !armed else { return }
        armed = true
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        for name in ["shot", "explode", "death", "pickup", "win", "lose", "jeep"] {
            if let url = Bundle.main.url(forResource: name, withExtension: "wav", subdirectory: "SFX")
                ?? Bundle.main.url(forResource: name, withExtension: "wav"),
               let player = try? AVAudioPlayer(contentsOf: url) {
                player.prepareToPlay()
                players[name] = player
            }
        }
    }

    static func play(_ name: String) {
        boot()
        guard let player = players[name] else { return }
        player.currentTime = 0
        player.play()
    }
}

/// Title-screen intro theme: original march MIDI rendered through iOS's built-in GM sound bank.
enum Music {
    private static var player: AVMIDIPlayer?

    static func playIntroLoop() {
        guard player == nil,
              let url = Bundle.main.url(forResource: "intro", withExtension: "mid", subdirectory: "SFX")
                ?? Bundle.main.url(forResource: "intro", withExtension: "mid")
        else { return }
        let midi = try? AVMIDIPlayer(contentsOf: url, soundBankURL: nil)
        midi?.prepareToPlay()
        player = midi
        loop()
    }

    private static func loop() {
        guard let player else { return }
        player.currentPosition = 0
        player.play {
            DispatchQueue.main.async { loop() }
        }
    }

    static func stop() {
        player?.stop()
        player = nil
    }
}
