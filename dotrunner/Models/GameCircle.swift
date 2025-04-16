import SwiftUI
import Foundation

/// Model representing an interactive circle in the game
struct GameCircle: Identifiable, Equatable {
    let id = UUID()
    var color: CircleColor
    var position: CGPoint
    var scale: CGFloat = 1.0
    var opacity: Double = 1.0
    
    /// Size for the specific vegetable type
    var size: CGFloat {
        switch color {
        case .bomb:
            return Constants.UI.bombSize
        case .beetroot:
            return Constants.UI.beetrootSize
        default:
            return Constants.UI.standardCircleSize
        }
    }
    
    /// Implement Equatable
    static func == (lhs: GameCircle, rhs: GameCircle) -> Bool {
        return lhs.id == rhs.id &&
               lhs.color == rhs.color &&
               lhs.position == rhs.position &&
               lhs.scale == rhs.scale &&
               lhs.opacity == rhs.opacity
    }
}

/// Model for power-ups
struct PowerUp: Identifiable {
    let id = UUID()
    let type: PowerUpType
    var position: CGPoint
    var scale: CGFloat = 1.0
    var opacity: Double = 1.0
} 