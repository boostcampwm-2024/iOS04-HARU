final class Room {
    private var users: [User] = []
    private var maxCount: Int = 4
    let roomID: String

    init(roomID: String) {
        self.roomID = roomID
    }
    
    @discardableResult
    func invite(user: User) -> Bool {
        guard users.count < maxCount else { return false }
        users.append(user)
        return true
    }
    
    @discardableResult
    func kick(userID: String) -> Bool {
        let filtered = users.filter { $0.id != userID }
        users = filtered
        return filtered.isEmpty // 필터에 걸렸으면 찾은 것
    }
}
