import SwiftUI

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
}

enum AppView{
    case main, startnewtest, archive, info
}
class ViewRouter: ObservableObject{
    @Published var currentView: AppView = .main
}

@main
struct FormaldehydeApp: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var viewRouter = ViewRouter()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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
