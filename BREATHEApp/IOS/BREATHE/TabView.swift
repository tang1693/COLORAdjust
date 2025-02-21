//
//  TabView.swift
//  BREATHE
//
//  Created by Guixiang Zhang on 6/24/21.
//

import SwiftUI


struct TabView: View {
    var items: [TabBarItem]
    @EnvironmentObject private var viewRouter: ViewRouter
    
    init(_ items: [TabBarItem]) {
        self.items = items
        
    }
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .foregroundColor(Color("TabBarBackground"))
            HStack {
                Button (action: {
                    viewRouter.currentView = .main
                }) {
                    VStack(spacing: 0){
                        if viewRouter.currentView == .main {
                            self.items[0].image.renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/)
                                .resizable()
                                .frame(width: 50, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .foregroundColor(.blue)
                                .padding(.top, 5)
                            Text(self.items[0].title)
                                .accentColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                .font(Font.system(size: 18, weight: .bold))
                                .padding(.bottom, 12)
                        } else {
                            self.items[0].image
                                .resizable()
                                .frame(width: 50, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .padding(.top, 5)
                            Text(self.items[0].title)
                                .accentColor(.black)
                                .font(Font.system(size: 18, weight: .bold))
                                .padding(.bottom, 12)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Button (action: {
                    viewRouter.currentView = .archive
                }) {
                    VStack(spacing: 0){
                        if viewRouter.currentView == .archive {
                            self.items[1].image.renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/)
                                .resizable()
                                .frame(width: 50, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .foregroundColor(.blue)
                                .padding(.top, 5)
                            Text(self.items[1].title)
                                .accentColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                .font(Font.system(size: 18, weight: .bold))
                                .padding(.bottom, 12)
                        } else {
                            self.items[1].image
                                .resizable()
                                .frame(width: 50, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .padding(.top, 5)
                            Text(self.items[1].title)
                                .accentColor(.black)
                                .font(Font.system(size: 18, weight: .bold))
                                .padding(.bottom, 12)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Button (action: {
                    viewRouter.currentView = .info
                }) {
                    VStack(spacing: 0){
                        if viewRouter.currentView == .info {
                            self.items[2].image.renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/)
                                .resizable()
                                .frame(width: 50, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .foregroundColor(.blue)
                                .padding(.top, 5)
                            Text(self.items[2].title)
                                .accentColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                .font(Font.system(size: 18, weight: .bold))
                                .padding(.bottom, 12)
                        } else {
                            self.items[2].image
                                .resizable()
                                .frame(width: 50, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .padding(.top, 5)
                            Text(self.items[2].title)
                                .accentColor(.black)
                                .font(Font.system(size: 18, weight: .bold))
                                .padding(.bottom, 12)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct TabBarItem {
    var image: Image
    var title: String
    
    init(image: Image, title: String) {
        self.image = image
        self.title = title
    }
}
