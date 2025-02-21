//
//  ContentView.swift
//  BREATHE
//
//  Created by Shaun Song on 2021/4/19.
//  Modified by Guixiang Zhang on 2021/6/25.
//

import SwiftUI

struct MainFrameView: View {
    @EnvironmentObject private var viewRouter: ViewRouter
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().barTintColor = UIColor(named: "NavigationBarBackground")
    }
    
    var body: some View {
        if viewRouter.currentView == .main {
            NavigationView{
                HomeView()
                    .navigationTitle("BREATHE-Smart")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarBackButtonHidden(true)
            }.navigationViewStyle(StackNavigationViewStyle())
        } else if viewRouter.currentView == .startnewtest {
            NavigationView{
                StartTestView()
                    .navigationTitle("BREATHE-Smart")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(leading: btnBack)
            }.navigationViewStyle(StackNavigationViewStyle())
        } else if viewRouter.currentView == .archive {
            NavigationView{
                ArchiveView()
                    .navigationTitle("BREATHE-Smart")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarBackButtonHidden(true)
            }.navigationViewStyle(StackNavigationViewStyle())
        } else if viewRouter.currentView == .info {
            NavigationView{
                AboutView()
                    .navigationTitle("BREATHE-Smart")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarBackButtonHidden(true)
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    var btnBack : some View {
        Button(action: {
            viewRouter.currentView = .main
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .foregroundColor(.black)
        }
    }
}

struct MainFrameView_Previews: PreviewProvider {
    static var previews: some View {
        MainFrameView().environmentObject(ViewRouter())
    }
}
