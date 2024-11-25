//
//  SettingView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/10/18.
//

import SwiftUI

struct SettingView: View {
    @State private var toggleState1 = false
    @State private var toggleState2 = true
    var body: some View {
        ZStack{
            //カラーストップのグラデーション
            Image("Background")
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                VStack{
                    // Handle at the top
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray)
                        .frame(width: 90, height: 5)
                    
                    VStack{
                        
                        Text("設定画面")
                            .font(.title)
                        
                        Link(destination: URL(string: "https://apps.apple.com/jp/app/id6553989978?action=write-review")!) {
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 30))
                                Text("レビューを書く")
                                    .foregroundColor(.black)
                                    .font(.system(size: 30)) // Increase font size for larger text
                                    .padding(.leading,2)
                                
                                Spacer()
                                
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .frame(height: 60) // Set height for each row
                        .background(Color.white)
                        .cornerRadius(10)
                        
                        ShareLink(item: URL(string: "https://apps.apple.com/us/app/japan-travel-yokoso/id6553989978")!) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 30))
                                
                                Text("アプリをシェアする")
                                    .foregroundColor(.black)
                                    .font(.system(size: 30)) // Increase font size for larger text
                                    .padding(.leading,2)
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .frame(height: 60) // Set height for each row
                        .background(Color.white)
                        .cornerRadius(10)
                        
                        NavigationLink(destination: TermsView()) {
                            HStack {
                                Image(systemName: "exclamationmark.lock")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 30))
                                
                                Text("利用規約")
                                    .foregroundColor(.black)
                                    .font(.system(size: 30)) // Increase font size for larger text
                                    .padding(.leading,2)
                                
                                Spacer()
                                
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .frame(height: 60) // Set height for each row
                        .background(Color.white)
                        .cornerRadius(10)
                        
                        NavigationLink(destination: PrivacyPolicyView()) {
                            HStack {
                                Image(systemName: "hand.raised")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 30))
                                
                                Text("プライパシーポリシー")
                                    .foregroundColor(.black)
                                    .font(.system(size: 30)) // Increase font size for larger text
                                    .padding(.leading,2)
                                
                                Spacer()
                                
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .frame(height: 60) // Set height for each row
                        .background(Color.white)
                        .cornerRadius(10)
                        NavigationLink(destination: SettingGift()) {
                            HStack {
                                Image(systemName: "gift.fill")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 30))
                                
                                Text("エンジニアに寄付")
                                    .foregroundColor(.black)
                                    .font(.system(size: 30)) // Increase font size for larger text
                                    .padding(.leading,2)
                                Spacer()
                                
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .frame(height: 60) // Set height for each row
                        .background(Color.white)
                        .cornerRadius(10)
                        
                        Toggle(isOn: $toggleState1) {
                            HStack{
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.black)
                                    .font(.system(size: 30))
                                    .padding(.leading,20)
                                
                                Text("通知")
                                    .font(.system(size: 30))
                                    .padding(.leading,2)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color.orange))
                        .padding(.bottom,10)
                        .padding(.trailing,10)
                        
                    }
                    Spacer()
                }
                
                .padding(.top,20)
                .frame(maxWidth: .infinity,maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(40)
                .shadow(radius: 5)
                .ignoresSafeArea(edges: .bottom)
                
                
                
            }.padding(.top,30)
        }
    }
}

#Preview {
    SettingView()
}
