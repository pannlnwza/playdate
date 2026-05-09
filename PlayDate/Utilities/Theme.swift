import SwiftUI

enum Theme {
    static let primary = Color(red: 1.0, green: 107/255, blue: 107/255)
    static let primaryDark = Color(red: 229/255, green: 90/255, blue: 90/255)
    static let secondary = Color(red: 78/255, green: 205/255, blue: 196/255)
    static let accent = Color(red: 1.0, green: 230/255, blue: 109/255)
    static let purple = Color(red: 167/255, green: 139/255, blue: 250/255)
    static let blue = Color(red: 96/255, green: 165/255, blue: 250/255)
    static let pink = Color(red: 249/255, green: 168/255, blue: 212/255)
    static let orange = Color(red: 251/255, green: 146/255, blue: 60/255)

    static let bg = Color(red: 1.0, green: 248/255, blue: 240/255)
    static let cardBg = Color.white
    static let textMain = Color(red: 45/255, green: 52/255, blue: 54/255)
    static let textLight = Color(red: 99/255, green: 110/255, blue: 114/255)
    static let textMuted = Color(red: 178/255, green: 190/255, blue: 195/255)

    static let brandGradient = LinearGradient(
        colors: [primary, purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let likeGradient = LinearGradient(
        colors: [secondary, Color(red: 69/255, green: 183/255, blue: 170/255)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardPalettes: [[Color]] = [
        [Color(red: 1.0, green: 236/255, blue: 210/255), Color(red: 252/255, green: 182/255, blue: 159/255)],
        [Color(red: 168/255, green: 237/255, blue: 234/255), Color(red: 254/255, green: 214/255, blue: 227/255)],
        [Color(red: 251/255, green: 194/255, blue: 235/255), Color(red: 166/255, green: 193/255, blue: 238/255)],
        [Color(red: 212/255, green: 252/255, blue: 121/255), Color(red: 150/255, green: 230/255, blue: 161/255)],
        [Color(red: 240/255, green: 147/255, blue: 251/255), Color(red: 245/255, green: 87/255, blue: 108/255)]
    ]

    static func palette(for seed: String) -> [Color] {
        let index = abs(seed.hashValue) % cardPalettes.count
        return cardPalettes[index]
    }
}
