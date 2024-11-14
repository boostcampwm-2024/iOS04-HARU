import UIKit

public extension UILabel {
    /// 자간을 설정하는 메소드입니다.
    /// - Parameter kernValue: 자간입니다.
    /// - Parameter lineBreakMode: 텍스트가 짤릴 경우 어떻게 처리할 것인지
    /// - Parameter alignment: 텍스트를 어떻게 정렬할 것인지
    func setKern(
        kernValue: Double? = -0.32,
        lineBreakMode: NSLineBreakMode = .byTruncatingTail,
        alignment: NSTextAlignment = .left
    ) {
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.alignment = alignment
        
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .kern: kernValue ?? 0.0
        ]
        let attributedString = NSMutableAttributedString(string: text ?? "", attributes: attributes)
        
        self.attributedText = attributedString
    }
}
