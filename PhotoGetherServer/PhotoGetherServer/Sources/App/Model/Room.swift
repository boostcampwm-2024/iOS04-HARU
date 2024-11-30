final class Room {
    private(set) var userList: [User] = []
    private var maxCount: Int = 4
    let roomID: String

    init(roomID: String) {
        self.roomID = roomID
    }
    
    @discardableResult
    func invite(user: User) -> Bool {
        guard userList.count < maxCount else { return false }
        userList.append(user)
        return true
    }
    
    @discardableResult
    func kick(userID: String) -> Bool {
        let filtered = userList.filter { $0.id != userID }
        userList = filtered
        return filtered.isEmpty // 필터에 걸렸으면 찾은 것
    }
}
