import SwiftUI

struct AppTheme {
    let accentColor: Color
    let backgroundColor: Color
    let surfaceColor: Color
    let textColor: Color

    static let `default` = AppTheme(
        accentColor: Color(red: 0.72, green: 1.00, blue: 0.17),
        backgroundColor: Color(.systemBackground),
        surfaceColor: Color(.secondarySystemBackground),
        textColor: Color(.label)
    )
}
