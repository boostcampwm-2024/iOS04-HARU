import UIKit
import WebRTC

// TODO: WebSocket에 접속한다
// TODO: constraint를 지정해준다(비디오, 오디오)

// MARK: OFFER
// TODO: sdp에 constraint를 담아준다(peerConnection.offer(for: Sconstrains))
// TODO: sdp를 peerConnection localDescription에 저장한다
// TODO: completion에서 socket에 전송해준다

// MARK: ANSWER
// TODO: sdp에 constraint를 담아준다(peerConnection.answer(for: Sconstrains))
// TODO: sdp peerConnection localDescription에 저장한다
// TODO: completion에서 socket에 전송해준다


// MARK: ICECandidate
// TODO:


// TODO: 버튼을 눌러 videoView를 띄운다
// TODO: 둘간의 통신이 일어난다

// ---------------------------------------
// SignalClientDidConnect <- webSocketDidConnect <- NativeWebSocket.urlSession(didOpenWithProtocol) <- signalingClient 클래스가 webSocketProvider, SignalClientDelegate를 갖고 있음

// MARK: offer 버튼의 completion
// completion 메서드 내부에서 signalClient.send(sdp)를 실행
// send 함스의 sdp 파라미터를 이용해서 SessionDescription을 생성해주고 이를 이용하여 메세지화 해준다
// 해당 메세지를 encode하고 webSocket.send(data)로 보낸다
// NativeWebSocket(URLSessionWebSocketTask).send(URLSessionWebSocketTask.data) 해주고 끝난다

public class WaitingRoomViewController: UIViewController {
    private let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                   kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
    
    
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }
}
