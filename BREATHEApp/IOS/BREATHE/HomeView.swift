//
//  HomeView.swift
//  BREATHE
//
//  Created by Shaun Song on 2021/4/20.
//

import SwiftUI

struct HomeView: View{
    @EnvironmentObject private var viewRouter: ViewRouter
    var body: some View{
        VStack{
            Button(action: {
                viewRouter.currentView = .startnewtest
            }){
                HStack{
                    Image(systemName: "plus").font(.system(size:36)).foregroundColor(Color("ButtonForeground"))
                    Text("START NEW TEST").fontWeight(.bold)
                        .font(.title)
                        .foregroundColor(Color("ButtonForeground"))
                }.padding(32)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color("ButtonBackground")))
            }
            Spacer()
            TabView([
                TabBarItem(image: Image("BreatheIcon_ag"), title: "Home"),
                TabBarItem(image: Image("SafeIcon_ag"), title: "Archive"),
                TabBarItem(image: Image("info icon"), title: "Info"),
            ]).frame(height: 90)
        }
    }
}

struct HomeView_Previews : PreviewProvider
{
    static var previews: some View{
        HomeView()
    }
}

