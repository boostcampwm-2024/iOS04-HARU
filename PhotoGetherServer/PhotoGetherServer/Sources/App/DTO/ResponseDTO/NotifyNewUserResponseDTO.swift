import Foundation

package struct NotifyNewUserResponseDTO: Encodable {
    let newUser: UserDTO
    
    package init(newUser: UserDTO) {
        self.newUser = newUser
    }
}
