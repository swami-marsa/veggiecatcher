import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var backgroundMusicPlayer: AVAudioPlayer?
    
    private var effectsEnabled: Bool = true
    private var musicEnabled: Bool = true
    
    private let effectsVolume: Float = 1.0
    private let musicVolume: Float = 0.3
    
    init() {
        setupAudioSession()
        preloadSounds()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️ Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    private func preloadSounds() {
        let soundFiles = [
            ("swipe", "mp3"),
            ("bombtick", "mp3"),
            ("explosion", "mp3"),
            ("game_home", "mp3"),
            ("game_play", "mp3"),
            ("gamebonus", "mp3"),
            ("levelfail", "mp3"),
            ("levelwin", "mp3")
        ]
        
        for (name, ext) in soundFiles {
            if let soundURL = Bundle.main.url(forResource: name, withExtension: ext) {
                do {
                    let player = try AVAudioPlayer(contentsOf: soundURL)
                    player.prepareToPlay()
                    audioPlayers[name] = player
                    print("✅ Loaded sound: \(name)")
                } catch {
                    print("⚠️ Error loading sound \(name): \(error.localizedDescription)")
                }
            } else {
                print("⚠️ Could not find sound file: \(name).\(ext)")
            }
        }
    }
    
    func playBackgroundMusic(_ name: String) {
        if !musicEnabled {
            return
        }
        
        stopBackgroundMusic()
        
        guard let soundURL = Bundle.main.url(forResource: name, withExtension: "mp3"),
              let player = try? AVAudioPlayer(contentsOf: soundURL) else {
            print("⚠️ No player found for background music: \(name)")
            return
        }
        
        player.numberOfLoops = -1
        player.volume = musicVolume
        
        if player.play() {
            print("▶️ Playing background music: \(name)")
            backgroundMusicPlayer = player
        } else {
            print("⚠️ Failed to play background music: \(name)")
        }
    }
    
    func playSound(_ name: String, loop: Bool = false) {
        // Check if this is a game sound (background music) or a sound effect
        let isGameSound = name.contains("game_")
        
        // Don't play sound effects if they're disabled
        if !effectsEnabled && !isGameSound {
            // Skip playing the sound if effects are disabled and this isn't a game sound
            print("ℹ️ Sound effect skipped (disabled): \(name)")
            return
        }
        
        guard let player = audioPlayers[name] else {
            print("⚠️ No player found for sound: \(name)")
            return
        }
        
        player.currentTime = 0
        player.numberOfLoops = loop ? -1 : 0
        player.volume = isGameSound ? musicVolume : effectsVolume
        
        if !player.play() {
            print("⚠️ Failed to play sound: \(name)")
        }
    }
    
    func stopSound(_ name: String) {
        audioPlayers[name]?.stop()
        audioPlayers[name]?.currentTime = 0
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }
    
    func stopAllSounds() {
        stopBackgroundMusic()
        for player in audioPlayers.values {
            player.stop()
            player.currentTime = 0
        }
    }
    
    func isPlaying(_ name: String) -> Bool {
        guard let player = audioPlayers[name] else {
            return false
        }
        return player.isPlaying
    }
    
    func setMusicEnabled(_ enabled: Bool) {
        musicEnabled = enabled
        if !enabled {
            stopBackgroundMusic()
        }
    }
    
    func setEffectsEnabled(_ enabled: Bool) {
        effectsEnabled = enabled
    }
} 