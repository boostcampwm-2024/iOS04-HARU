import Vapor

extension WebSocket {
    func decodeDTO<T: Decodable>(
        data: ByteBuffer,
        type: T.Type,
        decoder: JSONDecoder
    ) -> T? {
        guard let dto = data.toDTO(type: type, decoder: decoder) else {
            print("[DEBUG] :: Decode Failed: \(type) \(data.readableBytes)")
            return nil
        }
        return dto
    }
    
    func decodeDTO<T: Decodable>(
        data: Data,
        type: T.Type,
        decoder: JSONDecoder
    ) -> T? {
        guard let dto = data.toDTO(type: type, decoder: decoder) else {
            print("[DEBUG] :: Decode Failed: \(type) \(data.count)")
            return nil
        }
        return dto
    }
}
