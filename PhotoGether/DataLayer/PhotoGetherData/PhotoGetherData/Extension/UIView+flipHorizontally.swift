import WebRTC

extension RTCVideoRenderer {
    /// 좌우반전
    func flipHorizontally() -> Self {
        (self as! UIView).transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        return self
    }
}
