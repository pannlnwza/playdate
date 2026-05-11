import UIKit

extension UIImage {
    func compressedJPEG(maxDimension: CGFloat, quality: CGFloat) -> Data? {
        let scale = min(maxDimension / size.width, maxDimension / size.height, 1)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let resized = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: quality)
    }

    func compressedJPEGUnderBudget(_ maxBytes: Int, startMaxDimension: CGFloat = 800) -> Data? {
        var dimension = startMaxDimension
        for quality in stride(from: 0.7, through: 0.2, by: -0.1) {
            if let data = compressedJPEG(maxDimension: dimension, quality: CGFloat(quality)),
               data.count <= maxBytes {
                return data
            }
            dimension = max(dimension * 0.85, 320)
        }
        return compressedJPEG(maxDimension: 320, quality: 0.2)
    }
}
