import Vapor

func routes(_ app: Application) throws {
    var connections = [WebSocket]()
    
    // WebSocket 연결을 처리하는 라우트
    app.webSocket("signaling") { req, ws in
        connections.append(ws)
        
        // 클라이언트가 연결될 때 호출
        print("Client connected. Total connected clients: \(connections.count)")
        
        // 클라이언트로부터 데이터를 수신할 때 호출
        ws.onBinary { ws, data in
            print("Received binary data of size: \(data.readableBytes)")
            connections.forEach { connection in
                if connection !== ws {
                    connection.send(data)
                }
            }
        }

        // 클라이언트가 연결을 종료할 때 호출
        ws.onClose.whenComplete { _ in
            connections.removeAll { $0 === ws }
            print("Client disconnected. Total connected clients: \(connections.count)")
        }
    }
}
