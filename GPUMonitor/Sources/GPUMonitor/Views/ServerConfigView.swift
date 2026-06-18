import SwiftUI

struct ServerListView: View {
    @ObservedObject var viewModel: GPUMonitorViewModel
    let onClose: (() -> Void)?
    @State private var showAddSheet = false
    @State private var editingServer: ServerConfig?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Servers")
                    .font(.headline)
                Spacer()
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            if viewModel.servers.isEmpty {
                VStack(spacing: 8) {
                    Text("No servers configured")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Button("Add Server") {
                        showAddSheet = true
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.servers) { server in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(server.name.isEmpty ? server.host : server.name)
                                    .font(.system(size: 13, weight: .medium))
                                Text(server.displayHost)
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: { editingServer = server }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 12))
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.blue)

                            Button(action: { viewModel.removeServer(server.id) }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 12))
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.red)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.inset)
            }

            HStack {
                Spacer()
                Button("Done") {
                    onClose?()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .frame(width: 400, height: 350)
        .sheet(isPresented: $showAddSheet) {
            ServerEditView(viewModel: viewModel, config: nil, onSave: { showAddSheet = false })
        }
        .sheet(item: $editingServer) { server in
            ServerEditView(viewModel: viewModel, config: server, onSave: { editingServer = nil })
        }
    }
}

struct ServerEditView: View {
    @ObservedObject var viewModel: GPUMonitorViewModel
    let config: ServerConfig?
    let onSave: (() -> Void)?

    @State private var name: String = ""
    @State private var host: String = ""
    @State private var port: String = "22"
    @State private var user: String = ""
    @State private var authType: AuthType = .key
    @State private var keyPath: String = "~/.ssh/id_rsa"
    @State private var keyBookmark: Data?
    @State private var password: String = ""

    init(viewModel: GPUMonitorViewModel, config: ServerConfig? = nil, onSave: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.config = config
        self.onSave = onSave
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
            Text(config == nil ? "Add Server" : "Edit Server")
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
                    onSave?()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Save") {
                    saveConfig()
                    onSave?()
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
        let newConfig = ServerConfig(
            id: config?.id ?? UUID(),
            name: name,
            host: host,
            port: Int(port) ?? 22,
            user: user,
            authType: authType,
            keyPath: keyPath,
            keyBookmark: keyBookmark,
            password: password
        )
        if config != nil {
            viewModel.updateServer(newConfig)
        } else {
            viewModel.addServer(newConfig)
        }
    }
}
