import UIKit
import Foundation

// Define CircleView delegate protocol
protocol CircleViewDelegate: AnyObject {
    func didTapCircle(_ circle: CircleView)
    func tryPlayBombTickSound(for circle: CircleView)
}

// Define CircleView class
class CircleView: UIView {
    var isBomb: Bool
    var position: CGPoint
    weak var delegate: CircleViewDelegate?
    
    init(position: CGPoint, diameter: CGFloat, isBomb: Bool) {
        self.position = position
        self.isBomb = isBomb
        super.init(frame: CGRect(x: position.x - diameter/2, y: position.y - diameter/2, width: diameter, height: diameter))
        self.backgroundColor = isBomb ? .red : .green
        self.layer.cornerRadius = diameter / 2
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleTap() {
        delegate?.didTapCircle(self)
    }
}

// Simplified Game class
class Game {
    var level: Int = 1
    var score: Int = 0
    var paused: Bool = false
    var isPlaying: Bool = true
}

// Now the main game area class
class UICircleGameArea: UIView, CircleViewDelegate {

    // MARK: - Properties

    private var game: Game!
    private var circles: [CircleView] = []
    private var spawnTimer: Timer?

    // MARK: - Initialization

    init(game: Game) {
        super.init(frame: .zero)
        self.game = game
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        // Add any additional setup code here
    }
    
    // MARK: - CircleViewDelegate
    
    func didTapCircle(_ circle: CircleView) {
        // Handle circle tap event
        if circle.isBomb {
            // Handle bomb tap
            SoundManager.shared.playSound(Constants.Sounds.explosion)
        } else {
            // Handle vegetable tap
            SoundManager.shared.playSound(Constants.Sounds.swipe)
        }
        
        // Remove circle from view and array
        circle.removeFromSuperview()
        if let index = circles.firstIndex(where: { $0 === circle }) {
            circles.remove(at: index)
        }
    }

    // MARK: - Spawning Logic

    func startSpawning() {
        // Use a deterministic timer to ensure consistent spawning
        self.spawnTimer?.invalidate()
        
        let initialDelay = 0.5
        
        // Use a more consistent approach for scheduling spawns
        self.spawnTimer = Timer.scheduledTimer(withTimeInterval: initialDelay, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Check if we should continue spawning
            if self.game.paused || !self.game.isPlaying {
                return
            }
            
            self.spawnCircle()
            
            // Adjust the timer interval based on current game level
            let newInterval = max(0.8, min(1.5, 2.0 - (Double(self.game.level) * 0.1)))
            
            // Reset the timer with the new interval
            self.spawnTimer?.invalidate()
            self.spawnTimer = Timer.scheduledTimer(
                withTimeInterval: newInterval,
                repeats: true
            ) { [weak self] _ in
                self?.spawnCircle()
            }
        }
    }

    func stopSpawning() {
        // Clean up timer
        self.spawnTimer?.invalidate()
        self.spawnTimer = nil
    }

    func spawnCircle() {
        // Basic guard to ensure we're in a valid game state
        guard !game.paused && game.isPlaying else { return }
        
        // Don't create too many circles to avoid performance issues
        if circles.count >= 25 {
            return
        }
        
        // Determine if we should spawn a bomb or vegetable
        let spawnBomb = shouldSpawnBomb()
        
        // Create new circle
        let circle = createCircle(isBomb: spawnBomb)
        
        // Fade in animation to improve performance
        circle.alpha = 0
        UIView.animate(withDuration: 0.2) {
            circle.alpha = 1.0
        }
        
        // Add to view and track
        self.addSubview(circle)
        circles.append(circle)
        
        // Play bomb tick sound if needed
        if spawnBomb {
            tryPlayBombTickSound(for: circle)
        }
    }

    private func shouldSpawnBomb() -> Bool {
        // Random chance of spawning bomb based on level
        let bombChancePercent = min(25, 5 + (game.level * 2))
        let shouldSpawnBomb = Int.random(in: 1...100) <= bombChancePercent
        
        // Don't spawn bombs at the very beginning
        if game.score < 5 {
            return false
        }
        
        return shouldSpawnBomb
    }

    private func createCircle(isBomb: Bool) -> CircleView {
        // Create a random position that's visible in the game area
        let edgePadding: CGFloat = 30
        let x = CGFloat.random(in: edgePadding...(self.bounds.width - edgePadding))
        let y = CGFloat.random(in: edgePadding...(self.bounds.height - edgePadding))
        
        // Size based on level, smaller as level increases for challenge
        let baseDiameter: CGFloat = 80
        let sizeReduction = CGFloat(game.level) * 1.5
        let diameter = max(50, baseDiameter - sizeReduction)
        
        // Create circle view
        let circle = CircleView(
            position: CGPoint(x: x, y: y),
            diameter: diameter,
            isBomb: isBomb
        )
        circle.delegate = self
        
        return circle
    }

    func tryPlayBombTickSound(for circle: CircleView) {
        // Skip if not a bomb
        guard circle.isBomb else { return }
        
        // Safely play the bomb tick sound for bombs
        DispatchQueue.main.async {
            SoundManager.shared.playSound(Constants.Sounds.bombTick)
        }
    }
} 