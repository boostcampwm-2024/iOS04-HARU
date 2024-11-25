import Foundation
import PhotoGetherDomainInterface

public final class WebSocketClientImpl: NSObject, WebSocketClient {
    public var delegates: [WebSocketClientDelegate] = []
    private let url: URL
    private var socket: URLSessionWebSocketTask?
    
    public init(url: URL) {
        self.url = url
    }
    
    public func connect() {
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let socket = urlSession.webSocketTask(with: url)
        socket.resume()
        self.socket = socket
        self.readMessage()
    }
    
    public func send(data: Data) {
        self.socket?.send(.data(data)) { _ in }
    }
    
    private func readMessage() {
        self.socket?.receive { [weak self] message in
            guard let self else { return }
            
            switch message {
            case .success(.data(let data)):
                self.delegates.forEach{
                    $0.webSocket(self, didReceiveData: data)
                }
                self.readMessage()
                
            case .success:
                debugPrint("데이터 형식이 맞지 않습니다.")
                self.readMessage()

            case .failure:
                self.disconnect()
            }
        }
    }
    
    private func disconnect() {
        self.socket?.cancel()
        self.socket = nil
        self.delegates.forEach {
            $0.webSocketDidDisconnect(self)
        }
    }
}

extension WebSocketClientImpl: URLSessionWebSocketDelegate, URLSessionDelegate {
    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        self.delegates.forEach {
            $0.webSocketDidConnect(self)
        }
    }
    
    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        self.disconnect()
    }
}
