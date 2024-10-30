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
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 225/255, green: 255/255, blue: 203/255), // #E1FFCB
                    Color(red: 255/255, green: 242/255, blue: 209/255)  // #FFF2D1
                ]),
                startPoint: .top,
                endPoint: .bottom
            ).edgesIgnoringSafeArea(.all)
            
            VStack{
                // プロフィール画面
                HStack{
                    Spacer()
                    
                    VStack{
                        Circle()
                            .frame(width: 100,height: 100)
                        Text("名前")
                    }
                    
                    Spacer()
                }.padding(.bottom,20)
                
                
                VStack{
                    // Handle at the top
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray)
                        .frame(width: 90, height: 5)
                    
                    VStack{
                        HStack {
                            Text("設定")
                                .foregroundColor(.black)
                                .font(.system(size: 30)) // Increase font size for larger text
                                .padding(.leading)
                            
                            Spacer()
                            
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                            
                            
                        }
                        .padding()
                        .frame(height: 60) // Set height for each row
                        .background(Color.white)
                        .cornerRadius(10)
                        
                        HStack {
                            Text("設定")
                                .foregroundColor(.black)
                                .font(.system(size: 30)) // Increase font size for larger text
                                .padding(.leading)
                            
                            Spacer()
                            
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                            
                            
                        }
                        .padding()
                        .frame(height: 60) // Set height for each row
                        .background(Color.white)
                        .cornerRadius(10)
                        
                        HStack {
                            Text("設定")
                                .foregroundColor(.black)
                                .font(.system(size: 30)) // Increase font size for larger text
                                .padding(.leading)
                            Spacer()
                            
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                            
                            
                        }
                        .padding()
                        .frame(height: 60) // Set height for each row
                        .background(Color.white)
                        .cornerRadius(10)
                        
                        HStack {
                            Text("設定")
                                .foregroundColor(.black)
                                .font(.system(size: 30)) // Increase font size for larger text
                                .padding(.leading)
                            
                            Spacer()
                            
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                            
                            
                            
                            
                        }
                        .padding()
                        .frame(height: 60) // Set height for each row
                        .background(Color.white)
                        .cornerRadius(10)
                        
                        Toggle(isOn: $toggleState1) {
                            Text("設定")
                                .font(.system(size: 30))
                                .padding(.leading,30)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color.gray))
                        .padding(.bottom,10)
                        
                        Toggle(isOn: $toggleState2) {
                            Text("設定")
                                .font(.system(size: 30))
                                .padding(.leading,30)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color.yellow))
                        
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
