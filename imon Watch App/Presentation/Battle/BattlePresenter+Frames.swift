import Foundation

// MARK: - View Frames & Positions

extension BattlePresenter {

    // Pet fights from the left, enemy from the right; sprites natively face left.

    private static let petOffsetX = 1
    private static let opponentOffsetX = 15

    /// Pet faces right (toward the enemy on the right).
    var petFrame: SpriteFrame {
        petAnimator.currentFrame.facing(.right)
    }

    /// Enemy faces left (toward the pet on the left).
    var opponentFrame: SpriteFrame {
        opponentAnimator.currentFrame.facing(.left)
    }

    /// Horizontal position of the active sprite — pet on the left,
    /// enemy on the right, projectiles cross through the centre.
    var activeOffsetX: Int {
        switch viewModel.phase {
        case .introPet, .introVS, .introEnemy, .choosing, .projectile, .opponentProjectile:
            return 8
        case .attacking:
            return Self.petOffsetX
        case .opponentAttacking, .defeat:
            return Self.opponentOffsetX
        case .impact:
            switch viewModel.lastRoundOutcome {
            case .playerHit: return Self.opponentOffsetX
            case .opponentHit: return Self.petOffsetX
            case .clash, .none: return 8
            }
        case .victory:
            return viewModel.result == .lose
                ? Self.opponentOffsetX : Self.petOffsetX
        }
    }

    /// Single active sprite — only one thing on screen at a time.
    var activeFrame: SpriteFrame {
        switch viewModel.phase {
        case .introPet:
            return petFrame
        case .introVS:
            // The flashing "VS" is drawn by the LCD flash layer, not a sprite.
            return .empty
        case .introEnemy:
            return opponentFrame
        case .choosing, .attacking:
            return petFrame
        case .projectile:
            // Raw frame — projectile already travels left→right.
            return petAnimator.currentFrame
        case .opponentAttacking:
            return opponentFrame
        case .opponentProjectile:
            // Raw frame — projectileReversed already goes R→L.
            return opponentAnimator.currentFrame
        case .impact:
            switch viewModel.lastRoundOutcome {
            case .playerHit: return opponentFrame
            case .opponentHit, .clash, .none:
                return petFrame
            }
        case .victory:
            return viewModel.result == .lose
                ? opponentFrame : petFrame
        case .defeat:
            return opponentFrame
        }
    }
}
