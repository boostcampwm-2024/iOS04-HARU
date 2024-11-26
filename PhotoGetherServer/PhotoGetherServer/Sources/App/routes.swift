import Foundation
import Vapor

func routes(_ app: Application) throws {
    // MARK: 객체 초기화
    let roomManager = RoomManager()
    let webSocketController = WebSocketController(roomManager: roomManager)
    
    // MARK: Controller에서 대신 처리
    app.webSocket("signaling") { req, client in
        webSocketController.handleConnection(req, client: client)
    }
}
