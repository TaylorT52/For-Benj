import SwiftUI
import CryptoKit

struct PhotoOfDayView: View {
    @State private var urls: [URL] = []
    @State private var todayURL: URL?

    private let ticker = Timer.publish(every: 3600, on: .main, in: .common)
                                    .autoconnect()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.6),
                        style: StrokeStyle(lineWidth: 2, dash: [6]))
                .background(Color.white)
                .cornerRadius(12)

            if let url = todayURL {
#if os(macOS)
                if let img = NSImage(contentsOf: url) {
                    Image(nsImage: img)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .cornerRadius(12)
                }
#else
                if let img = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .cornerRadius(12)
                }
#endif
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(.gray.opacity(0.6))
            }
        }
        .task { await scanBundle(); chooseImage() }
        .onReceive(ticker) { _ in chooseImage() }
    }

    private func scanBundle() async {
        guard let root = Bundle.main.resourceURL?
                .appendingPathComponent("photos") else { return }
        
        print("📦 Bundle path:", Bundle.main.bundlePath)
        print("🖼  Looking for:", root.path)

        var tmp: [URL] = []
        if let enumerator = FileManager.default.enumerator(at: root,
                                                           includingPropertiesForKeys: nil,
                                                           options: [.skipsHiddenFiles]) {
            for case let fileURL as URL in enumerator
            where !fileURL.hasDirectoryPath {
                tmp.append(fileURL)
            }
        }
        urls = tmp.sorted { $0.lastPathComponent < $1.lastPathComponent }
        print("📷 Found \(urls.count) photo(s) in bundle")
    }

    private func chooseImage() {
        guard !urls.isEmpty else { todayURL = nil; return }

        let todayUTC = Calendar(identifier: .gregorian)
                        .startOfDay(for: Date())
        let key      = ISO8601DateFormatter().string(from: todayUTC)

        let hash     = Insecure.SHA1.hash(data: Data(key.utf8))
        let word     = hash.withUnsafeBytes { $0.load(as: UInt32.self) }

        todayURL = urls[Int(word) % urls.count]
        print(todayURL)
    }
}
