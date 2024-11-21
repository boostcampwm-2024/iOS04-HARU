import Foundation

public protocol ConnectionRepository {
    var clients: [ConnectionClient] { get }
}
