import WebRTC

extension RTCVideoRenderer {
    /// 좌우반전을 토글합니다.
    @discardableResult
    @MainActor
    func flipHorizontally() async -> Self {
        guard let view = self as? UIView else { return self }
        
        // MARK: transform.a 는 CGAffineTransform.scaleX와 같음. x축의 scale 값이 -1.0인지 확인
        let isFlipped = view.transform.a == -1.0
        
        // MARK: transform 상태 토글
        view.transform = isFlipped ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1.0, y: 1.0)
        
        return self
    }
    
    /// 좌우반전을 토글합니다. (메인스레드에서 비동기로 실행됩니다)
    @discardableResult
    func flipHorizontally() -> Self {
        guard let view = self as? UIView else { return self }
        
        DispatchQueue.main.async {
            // MARK: transform.a 는 CGAffineTransform.scaleX와 같음. x축의 scale 값이 -1.0인지 확인
            let isFlipped = view.transform.a == -1.0
            
            // MARK: transform 상태 토글
            view.transform = isFlipped ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
        return self
    }
}
