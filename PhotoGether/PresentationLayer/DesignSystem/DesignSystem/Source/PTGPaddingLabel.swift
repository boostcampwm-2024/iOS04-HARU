import UIKit

public final class PTGPaddingLabel: UILabel {
    private let padding: UIEdgeInsets
    
    public init(padding: UIEdgeInsets = UIEdgeInsets(top: 3.5, left: 8.0, bottom: 3.5, right: 8.0)) {
        self.padding = padding
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    // 안에 내재되어있는 콘텐트의 사이즈에 따라 height와 width에 padding값을 더해줌
    public override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right
        
        return contentSize
    }
}
