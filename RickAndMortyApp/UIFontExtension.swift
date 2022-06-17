import UIKit

enum AppFonts {
    case SFDisplayBlack
    case SFDisplayBold
    case SFTextBold
    case SFTextSemibold
}

extension UIFont {
    static func appFont(_ name: AppFonts, _ size: CGFloat) -> UIFont? {
        switch name {
        case .SFDisplayBlack:
            return UIFont(name: "SFUIDisplay-Black", size: size)!
        case .SFDisplayBold:
            return UIFont(name: "SFUIDisplay-Bold", size: size)!
        case .SFTextBold:
            return UIFont(name: "SFUIText-Bold", size: size)!
        case .SFTextSemibold:
            return UIFont(name: "SFUIText-Semibold", size: size)!
        }
    }
}
