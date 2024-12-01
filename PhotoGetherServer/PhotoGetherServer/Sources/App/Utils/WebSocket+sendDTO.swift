import Vapor

extension WebSocket {
    @discardableResult
    func sendDTO<T: Encodable>(
        _ dto: T,
        encoder: JSONEncoder
    ) -> Bool {
        guard let data = dto.toData(encoder) else {
            print("[DEBUG] :: Encode Failed: \(dto)")
            return false
        }
        self.send(data)
        return true
    }
}
