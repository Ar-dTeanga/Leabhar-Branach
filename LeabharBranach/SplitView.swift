import SwiftUI

struct SplitView: View {
    let page: Int
    @State private var scrollOffset: CGFloat = 0
    @State private var lastDragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let paneHeight = geo.size.height / 4
            let width = geo.size.width

            VStack(spacing: 0) {
                manuscriptPane(width: width, paneHeight: paneHeight)
                Divider()
                textPane(suffix: "seanclo", font: .custom("Gadelica", size: 14), paneHeight: paneHeight)
                Divider()
                textPane(suffix: "latin", font: .system(size: 13, design: .serif), paneHeight: paneHeight)
                Divider()
                textPane(suffix: "english", font: .system(size: 13, design: .serif), paneHeight: paneHeight)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        scrollOffset = lastDragOffset - value.translation.height
                        scrollOffset = max(0, scrollOffset)
                    }
                    .onEnded { _ in
                        lastDragOffset = scrollOffset
                    }
            )
        }
    }

    private func manuscriptPane(width: CGFloat, paneHeight: CGFloat) -> some View {
        let imageName = String(format: "MS1288_%03d_8Bit", page)
        return Group {
            if let url = Bundle.main.url(forResource: imageName, withExtension: "jpeg", subdirectory: "jpeg_web"),
               let data = try? Data(contentsOf: url),
               let img = UIImage(data: data) {
                let imageHeight = (img.size.height / img.size.width) * width
                Image(uiImage: img)
                    .resizable()
                    .frame(width: width, height: imageHeight)
                    .offset(y: -scrollOffset)
            } else {
                Text("Image not available")
            }
        }
        .frame(width: width, height: paneHeight, alignment: .topLeading)
        .clipped()
    }

    private func textPane(suffix: String, font: Font, paneHeight: CGFloat) -> some View {
        let filename = String(format: "page_%03d_%@", page, suffix)
        let text: String = {
            guard let url = Bundle.main.url(forResource: filename, withExtension: "txt"),
                  let content = try? String(contentsOf: url, encoding: .utf8) else {
                return "Not yet available for page \(page)."
            }
            return content
        }()

        return Text(text)
            .font(font)
            .lineSpacing(4)
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .fixedSize(horizontal: false, vertical: true)
            .offset(y: -scrollOffset)
            .frame(height: paneHeight, alignment: .topLeading)
            .clipped()
    }
}

#Preview {
    SplitView(page: 31)
}
