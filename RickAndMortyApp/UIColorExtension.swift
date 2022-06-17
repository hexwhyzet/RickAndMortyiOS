import UIKit

enum AssetsColor {
    case main
    case secondary
    case greybg
    case bg
}

extension UIColor {
    static func appColor(_ name: AssetsColor) -> UIColor? {
        switch name {
        case .main:
            return UIColor(named: "MainColor")!
        case .secondary:
            return UIColor(named: "SecondaryColor")!
        case .greybg:
            return UIColor(named: "GreyBGColor")!
        case .bg:
            return UIColor(named: "BGColor")
        }
    }
}
