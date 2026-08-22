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
