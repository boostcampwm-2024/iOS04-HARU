import Vapor

struct User: Equatable {
    let id: String
    let client: WebSocket
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}
