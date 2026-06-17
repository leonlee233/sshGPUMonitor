import Foundation
import AppKit

class KeyFileManager {
    static let shared = KeyFileManager()

    private var accessUrls: [URL] = []

    private init() {}

    func selectKeyFile() -> (url: URL, bookmark: Data)? {
        let panel = NSOpenPanel()
        panel.title = "Select SSH Key File"
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".ssh")
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.showsHiddenFiles = true

        guard panel.runModal() == .OK, let url = panel.url else { return nil }

        guard let bookmark = try? url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        ) else { return nil }

        return (url, bookmark)
    }

    func resolveKeyPath(from bookmark: Data) -> String? {
        var isStale = false
        guard let url = try? URL(
            resolvingBookmarkData: bookmark,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        ) else { return nil }

        if url.startAccessingSecurityScopedResource() {
            accessUrls.append(url)
            return url.path
        }

        return url.path
    }

    func startAccessing(bookmark: Data) -> String? {
        var isStale = false
        guard let url = try? URL(
            resolvingBookmarkData: bookmark,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        ) else { return nil }

        if url.startAccessingSecurityScopedResource() {
            if !accessUrls.contains(url) {
                accessUrls.append(url)
            }
        }

        return url.path
    }

    func stopAllAccess() {
        for url in accessUrls {
            url.stopAccessingSecurityScopedResource()
        }
        accessUrls.removeAll()
    }
}
