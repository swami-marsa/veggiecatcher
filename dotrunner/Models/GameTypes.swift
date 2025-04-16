import SwiftUI
import Foundation

// MARK: - Game Item Types

/// Available vegetable colors/types
enum CircleColor: String, CaseIterable {
    case carrot, broccoli, corn, potato
    case beetroot, bottlegaurd, brinjal, cabbage
    case califlower, cucumber, mango, onion
    case bomb
    
    /// Image name for the vegetable
    var vegetableImage: String {
        switch self {
        case .bomb: return "red-broccoli"
        default: return rawValue
        }
    }
    
    /// Primary color for the vegetable
    var color: Color {
        switch self {
        case .carrot: return .orange
        case .broccoli: return .green
        case .corn: return .yellow
        case .potato: return .brown
        case .beetroot: return .red
        case .bottlegaurd: return .green
        case .brinjal: return .purple
        case .cabbage: return .green
        case .califlower: return .white
        case .cucumber: return .green
        case .mango: return .yellow
        case .onion: return .purple
        case .bomb: return .red
        }
    }
    
    /// Gradient colors for the vegetable
    var gradientColors: [Color] {
        switch self {
        case .carrot: return [.orange, .red]
        case .broccoli: return [.green, .teal]
        case .corn: return [.yellow, .orange]
        case .potato: return [.brown, .orange]
        case .beetroot: return [.red, .purple]
        case .bottlegaurd: return [.green, .mint]
        case .brinjal: return [.purple, .indigo]
        case .cabbage: return [.green, .mint]
        case .califlower: return [.white, .gray]
        case .cucumber: return [.green, .mint]
        case .mango: return [.yellow, .orange]
        case .onion: return [.purple, .pink]
        case .bomb: return [.red, .orange]
        }
    }
    
    /// Checks if this is a vegetable (not a bomb)
    var isVegetable: Bool {
        return self != .bomb
    }
}

/// Types of power-ups
enum PowerUpType {
    case extraLife
    case slowDown
} 