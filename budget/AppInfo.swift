//
//  AppInfo.swift
//  budget
//
//  Created by Lane Shukhov on 24.02.2023.
//

import SwiftUI

struct AppInfoView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Spacer()
                Image(uiImage: UIImage(named: "BigAppIcon") ?? UIImage())
                    .resizable()

                    .cornerRadius(20)
                    .padding(.bottom, 10)
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                Spacer()
            }
            .frame(minWidth: 200, idealWidth: 280, maxWidth: 290, minHeight: 200, idealHeight: 280, maxHeight: 290, alignment: .center)
            
            if let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
                Text(appName)
                    .font(.headline)
            } else {
                Text("Unknown app")
                    .font(.headline)
            }
            
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                Text("Version \(version)")
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            } else {
                Text("Version unknown")
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            }
                
            Text(NSLocalizedString("description", comment: ""))
                .font(.body)
                .lineSpacing(5)
                .padding(.bottom, 20)
            
            Text(NSLocalizedString("ai-powered", comment: ""))
                .font(.body)
                .lineSpacing(5)
                .padding(.bottom, 20)
            
            HStack {
                Image(systemName: "link")
                    .foregroundColor(.gray)
                Text("GitHub")
            }
            .padding(.bottom, 10)
            .onTapGesture {
                guard let url = URL(string: "https://github.com/rlshukhov/expense-pal") else { return }
                UIApplication.shared.open(url)
            }
        }
        .padding()
        .frame(width: 300)
    }
}
struct AppInfo_Previews: PreviewProvider {
    static var previews: some View {
        AppInfoView()
    }
}
