import SwiftUI

struct MainFrameView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var viewRouter: ViewRouter
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().barTintColor = UIColor(named: "NavigationBarBackground")
    }
    
    var body: some View {
        if viewRouter.currentView == .main {
            NavigationView{
                HomeView(sortDescripter: NSSortDescriptor(keyPath: \TestData.id, ascending: false))
                    .navigationTitle("BREATHE-Smart")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarBackButtonHidden(true)
            }.navigationViewStyle(StackNavigationViewStyle())
        } else if viewRouter.currentView == .startnewtest {
            NavigationView{
                NewTestView()
                    .navigationTitle("BREATHE-Smart")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarBackButtonHidden(true)
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
}

struct MainFrameView_Previews: PreviewProvider {
    static var previews: some View {
        MainFrameView().environmentObject(ViewRouter())
    }
}
