import UIKit
import DesignSystem

public extension UIViewController {
    private struct ToastState {
        static var presentedToast: UIView?
    }
    
    func showToast(message: String, duration: TimeInterval = 2.0) {
        // 이미 토스트가 있다면 제거
        if let existingToast = ToastState.presentedToast {
            existingToast.removeFromSuperview()
            ToastState.presentedToast = nil
        }
        
        let padding = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        let toastLabel: PTGPaddingLabel = {
            let lbl = PTGPaddingLabel(padding: padding)
            lbl.text = message
            lbl.textColor = .black
            lbl.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            lbl.textAlignment = .center
            lbl.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            lbl.numberOfLines = 1
            lbl.lineBreakMode = .byTruncatingTail
            lbl.setKern()
            lbl.layer.cornerRadius = 17.5
            lbl.layer.shadowOpacity = 0.25
            lbl.layer.shadowColor = UIColor.black.cgColor
            lbl.layer.shadowOffset = CGSize(width: 4, height: 4)
            lbl.clipsToBounds = true
            return lbl
        }()

        view.addSubview(toastLabel)
        ToastState.presentedToast = toastLabel
        
        let maxWidth: CGFloat = view.frame.width > 0 ? view.frame.width * 0.7 : 300

        toastLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.lessThanOrEqualTo(maxWidth)
            $0.height.equalTo(35)
        }
        
        toastLabel.transform = CGAffineTransform(translationX: 0, y: -30)
        toastLabel.alpha = 0
                
        // 보여지는 애니메이션
        let showAnimator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            toastLabel.transform = .identity
            toastLabel.alpha = 1
        }
        
        showAnimator.startAnimation()
        
        showAnimator.addCompletion { _ in
            // 사라지는 애니메이션
            let hideAnimator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
                toastLabel.transform = CGAffineTransform(translationX: 0, y: -30)
                toastLabel.alpha = 0
            }
            hideAnimator.startAnimation(afterDelay: duration)
            hideAnimator.addCompletion { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}
