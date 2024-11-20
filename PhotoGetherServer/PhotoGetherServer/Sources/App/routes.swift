import Vapor

var roomManager = RoomManager()

func routes(_ app: Application) throws {
    var connectedClients = [WebSocket]()
    
    // WebSocket 연결을 처리하는 라우트
    app.webSocket("signaling") { request, client in
        connectedClients.append(client)
        
        // 클라이언트가 연결될 때 호출
        print("Client connected. Total connected clients: \(connectedClients.count)")
        
        // 클라이언트로부터 데이터를 수신할 때 호출
        client.onBinary { client, data in
            
            // TODO: 1. data -> JSON으로 디코딩
            // TODO: 2. type을 보고 수행할 명령을 선택
            
            print("Received binary data of size: \(data.readableBytes)")
            connectedClients
                .filter { $0 !== client }
                .forEach { $0.send(data) }
        }

        // 클라이언트가 연결을 종료할 때 호출
        client.onClose.whenComplete { _ in
            connectedClients.removeAll { $0 === client }
            print("Client disconnected. Total connected clients: \(connectedClients.count)")
        }
    }
}
