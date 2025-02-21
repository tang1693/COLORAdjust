//
//  BREATHEApp.swift
//  BREATHE
//
//  Created by Shaun Song on 2021/4/19.
//  Modified by Guixiang Zhang on 2021/6/25.
//

import SwiftUI

enum AppView{
    case main, startnewtest, archive, info, testdata
}
class ViewRouter: ObservableObject{
    @Published var currentView: AppView = .main
}

@main
struct BREATHEApp: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var viewRouter = ViewRouter()
    
    var body: some Scene {
        WindowGroup {
            MainFrameView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(viewRouter)
        }.onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}
