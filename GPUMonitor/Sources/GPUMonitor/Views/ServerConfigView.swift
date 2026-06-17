import SwiftUI

struct ServerConfigView: View {
    @ObservedObject var viewModel: GPUMonitorViewModel
    let onClose: (() -> Void)?

    @State private var name: String = ""
    @State private var host: String = ""
    @State private var port: String = "22"
    @State private var user: String = ""
    @State private var authType: AuthType = .key
    @State private var keyPath: String = "~/.ssh/id_rsa"
    @State private var keyBookmark: Data?
    @State private var password: String = ""

    private var editingConfig: ServerConfig?

    init(viewModel: GPUMonitorViewModel, config: ServerConfig? = nil, onClose: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.editingConfig = config
        self.onClose = onClose
        if let config = config {
            _name = State(initialValue: config.name)
            _host = State(initialValue: config.host)
            _port = State(initialValue: "\(config.port)")
            _user = State(initialValue: config.user)
            _authType = State(initialValue: config.authType)
            _keyPath = State(initialValue: config.keyPath)
            _keyBookmark = State(initialValue: config.keyBookmark)
            _password = State(initialValue: config.password)
        }
    }

    private var isValid: Bool {
        !host.isEmpty && !user.isEmpty && Int(port) != nil
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(editingConfig == nil ? "Add Server" : "Edit Server")
                .font(.headline)

            Form {
                TextField("Name", text: $name)
                TextField("Host", text: $host)
                TextField("Port", text: $port)
                TextField("User", text: $user)
                Picker("Auth Type", selection: $authType) {
                    ForEach(AuthType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                if authType == .key {
                    HStack {
                        Text(keyPath)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .font(.system(size: 11))
                        Spacer()
                        Button("Browse...") {
                            selectKeyFile()
                        }
                    }
                } else {
                    SecureField("Password", text: $password)
                }
            }
            .formStyle(.grouped)

            HStack {
                Button("Cancel") {
                    onClose?()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Save") {
                    saveConfig()
                    onClose?()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isValid)
            }
        }
        .padding()
        .frame(width: 350, height: 320)
    }

    private func selectKeyFile() {
        if let result = KeyFileManager.shared.selectKeyFile() {
            keyPath = result.url.path
            keyBookmark = result.bookmark
        }
    }

    private func saveConfig() {
        let config = ServerConfig(
            id: editingConfig?.id ?? UUID(),
            name: name,
            host: host,
            port: Int(port) ?? 22,
            user: user,
            authType: authType,
            keyPath: keyPath,
            keyBookmark: keyBookmark,
            password: password
        )
        if editingConfig != nil {
            viewModel.updateServer(config)
        } else {
            viewModel.addServer(config)
        }
    }
}
