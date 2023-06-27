//
//  QRGeneratorService.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 26-06-23.
//

import SwiftUI

import UIKit
import CoreImage

struct QRGeneratorService {
    static func qrCode(text: String, size: CGSize) -> UIImage? {
        let data = text.data(using: String.Encoding.ascii)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: size.width, y: size.height)
        
        guard let outputImage = filter.outputImage?.transformed(by: transform) else {
            return nil
        }
        
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        let qrCodeImage = UIImage(cgImage: cgImage)
        return qrCodeImage
    }

}
