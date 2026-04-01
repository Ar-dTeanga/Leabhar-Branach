import SwiftUI

enum ViewMode: CaseIterable {
    case manuscript
    case seanclo
    case latin
    case english
    case split
}

struct ContentView: View {
    @State private var currentPage = 31
    @State private var pageInput = "31"
    @State private var viewMode: ViewMode = .manuscript

    private let totalPages = 39

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.77, green: 0.71, blue: 0.64)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                switch viewMode {
                case .manuscript:
                    manuscriptView
                case .seanclo:
                    singleTextView(suffix: "seanclo", font: .custom("Gadelica", size: 18))
                case .latin:
                    singleTextView(suffix: "latin", font: .system(size: 16, design: .serif))
                case .english:
                    singleTextView(suffix: "english", font: .system(size: 16, design: .serif))
                case .split:
                    SplitView(page: currentPage)
                }
            }
            .padding(.bottom, 70)

            navigationBar
        }
    }

    private var manuscriptView: some View {
        let imageName = String(format: "MS1288_%03d_8Bit", currentPage)
        return Group {
            if let url = Bundle.main.url(forResource: imageName, withExtension: "jpeg", subdirectory: "jpeg_web"),
               let data = try? Data(contentsOf: url),
               let img = UIImage(data: data) {
                let screenWidth = UIScreen.main.bounds.width
                let aspect = img.size.height / img.size.width
                let imageHeight = screenWidth * aspect
                ScrollView(.vertical, showsIndicators: true) {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenWidth, height: imageHeight)
                }
                .scrollBounceBehavior(.basedOnSize)
            } else {
                VStack {
                    Image(systemName: "doc.questionmark")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("Page \(currentPage) not available")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func singleTextView(suffix: String, font: Font) -> some View {
        let filename = String(format: "page_%03d_%@", currentPage, suffix)
        let text: String = {
            guard let url = Bundle.main.url(forResource: filename, withExtension: "txt"),
                  let content = try? String(contentsOf: url, encoding: .utf8) else {
                return "Transcription not yet available for page \(currentPage)."
            }
            return content
        }()

        return ScrollView {
            Text(text)
                .font(font)
                .lineSpacing(6)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var navigationBar: some View {
        GlassEffectContainer {
            HStack(spacing: 16) {
                Button(action: { go(-1) }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                .disabled(currentPage <= 1)
                .glassEffect(.regular.interactive(), in: .circle)

                TextField("", text: $pageInput)
                    .keyboardType(.numberPad)
                    .frame(width: 52, height: 44)
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .onSubmit { goToPage() }
                    .glassEffect(.regular, in: .capsule)

                Button(action: { go(1) }) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                .disabled(currentPage >= totalPages)
                .glassEffect(.regular.interactive(), in: .circle)

                Button(action: { cycleViewMode() }) {
                    Image(systemName: viewModeIcon)
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                .glassEffect(.regular.interactive(), in: .circle)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .padding(.bottom, 8)
    }

    private var viewModeIcon: String {
        switch viewMode {
        case .manuscript: return "photo"
        case .seanclo: return "textformat.abc"
        case .latin: return "character.book.closed"
        case .english: return "globe"
        case .split: return "rectangle.split.2x2"
        }
    }

    private func cycleViewMode() {
        let all = ViewMode.allCases
        let idx = all.firstIndex(of: viewMode)!
        viewMode = all[(idx + 1) % all.count]
    }

    private func go(_ delta: Int) {
        let newPage = max(1, min(totalPages, currentPage + delta))
        currentPage = newPage
        pageInput = "\(newPage)"
    }

    private func goToPage() {
        if let n = Int(pageInput) {
            let clamped = max(1, min(totalPages, n))
            currentPage = clamped
            pageInput = "\(clamped)"
        }
    }
}

#Preview {
    ContentView()
}
