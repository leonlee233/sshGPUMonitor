import Foundation

enum AuthType: String, Codable, CaseIterable {
    case key
    case password

    var displayName: String {
        switch self {
        case .key: return "SSH Key"
        case .password: return "Password"
        }
    }
}

struct ServerConfig: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var host: String
    var port: Int
    var user: String
    var authType: AuthType
    var keyPath: String
    var keyBookmark: Data?
    var password: String

    static func == (lhs: ServerConfig, rhs: ServerConfig) -> Bool {
        lhs.id == rhs.id
    }

    init(id: UUID = UUID(), name: String = "", host: String = "", port: Int = 22, user: String = "", authType: AuthType = .key, keyPath: String = "~/.ssh/id_rsa", keyBookmark: Data? = nil, password: String = "") {
        self.id = id
        self.name = name
        self.host = host
        self.port = port
        self.user = user
        self.authType = authType
        self.keyPath = keyPath
        self.keyBookmark = keyBookmark
        self.password = password
    }

    var displayHost: String {
        return "\(user)@\(host):\(port)"
    }
}
