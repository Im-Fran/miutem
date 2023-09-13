//
//  ImagePreview.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 13-09-23.
//

import SwiftUI

struct ImagePreview: View {
    
    var image: UIImage? = nil
    var imageUri: String? = "https://picsum.photos/400/400"
    
    var body: some View {
        ZStack {
            Color.black
            
            NavigationStack {
                VStack(alignment: .leading){
                    HStack(alignment: .top) {
                        // Back button
                    }
                    
                    Spacer()
                    
                    if imageUri != nil {
                        AsyncImage(url: URL(string: imageUri!)!)
                    } else {
                        Image(uiImage: image!)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(.black.opacity(0.95))
            }
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            if image == nil && imageUri == nil {
                
            }
        }
    }
}

struct ImagePreview_Previews: PreviewProvider {
    static var previews: some View {
        ImagePreview()
    }
}
