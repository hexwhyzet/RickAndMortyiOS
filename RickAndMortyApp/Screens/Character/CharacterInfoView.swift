import UIKit

final class InfoCell: UIView {
    
    struct Model {
        let key: String
        let value: String
    }
    
    init(frame: CGRect, containsDelimeter: Bool) {
        super.init(frame: frame)
        setup(containsDelimeter: containsDelimeter)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func update(with model: Model) {
        infoKeyLabel.text = model.key
        infoValueLabel.text = model.value
    }
    
    private func setup(containsDelimeter: Bool) {
        let stack = UIStackView()
        addSubview(stack)
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.contentMode = .left
        stack.axis = .vertical
        stack.spacing = 0
        
        stack.addArrangedSubview(infoKeyLabel)
        stack.addArrangedSubview(infoValueLabel)
        
        if (containsDelimeter) {
            stack.addArrangedSubview(delimiter)
        }
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leftAnchor.constraint(equalTo: leftAnchor),
            stack.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    private let infoKeyLabel: UILabel = {
        let ret = UILabel()
        ret.font = .appFont(.SFTextBold, 24)
        ret.textColor = UIColor.appColor(.secondary)
        ret.numberOfLines = 1
        return ret
    }()
    
    private let infoValueLabel: UILabel = {
        let ret = UILabel()
        ret.font = .appFont(.SFTextSemibold, 24)
        ret.textColor = UIColor.appColor(.main)
        ret.numberOfLines = 1
        return ret
    }()
    
    private let delimiter: Delimeter = Delimeter()
}

class Delimeter: UIView {
    private let lineWidth: CGFloat
    private let lineColor: UIColor
    
    init(frame: CGRect = .zero, lineWidth _lineWidth: CGFloat = 1.0, lineColor _lineColor: UIColor = UIColor.appColor(.main)!) {
        lineWidth = _lineWidth
        lineColor = _lineColor
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let midpoint = self.bounds.size.height / 2.0
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(lineWidth)
            context.setStrokeColor(lineColor.cgColor)
            context.move(to: CGPoint(x: 0.0, y: midpoint))
            context.addLine(to: CGPoint(x: self.bounds.size.width, y: midpoint))
            context.strokePath()
        }
    }
}
