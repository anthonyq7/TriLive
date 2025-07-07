//
//  ExtractedLogoandWelcomeview.swift
//  TriLive
//
//  Created by Brian Maina on 7/3/25.
//
import SwiftUI
import UIKit
import Foundation
import CoreLocation

struct ExtractedLogoAndWelcomeView: View { //MUST PLACE IN VSTACK
    var body: some View {
        VStack{
            Image("TriLiveLogo") //Logo
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .padding(.top, 25)
            
            HStack{

                Text("Welcome!") //This is the header
                    .font(.system(size: 38, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.leading, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding()
        }
    }
}
