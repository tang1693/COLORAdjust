import SwiftUI
import CoreData
import UserNotifications

struct HomeView: View{
    @EnvironmentObject private var viewRouter: ViewRouter
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest var items: FetchedResults<TestData>
    
    let fontSize: CGFloat = 32
    let dateformatter = DateFormatter()
    let timeformatter = DateFormatter()
    @State private var toBeDeleted: IndexSet? = nil
    @State private var showingDeleteAlert: Bool = false
    @State private var currentlyinprogress: [String] = []

    init(sortDescripter: NSSortDescriptor) {
        let request: NSFetchRequest<TestData> = TestData.fetchRequest()
        request.sortDescriptors = [sortDescripter]
        _items = FetchRequest<TestData>(fetchRequest: request)
        dateformatter.dateFormat = "MMMM dd, yyyy"
        timeformatter.dateFormat = "hh:mm a"
    }
    
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
            List {
                ForEach(items.filter({ ($0.inprogress) || ($0.ready) }), id: \.self) { item in
                    self.datawithlink(for: item)
                }
                .onDelete(perform: deleteItems)
            }
            Spacer()
            TabView([
                TabBarItem(image: Image("BreatheIcon_ag"), title: "Home"),
                TabBarItem(image: Image("SafeIcon_ag"), title: "Archive"),
                TabBarItem(image: Image("info icon"), title: "Info"),
            ]).frame(height: 80)
        }
    }
    private func deleteItems(at offsets: IndexSet) {
        self.toBeDeleted = offsets
        self.showingDeleteAlert = true
        for item in (items.filter({ ($0.inprogress) || ($0.ready) })) {
            self.currentlyinprogress.append(item.id!)
        }
    }
    private func datawithlink(for item: TestData) -> some View{
        NavigationLink(destination: ContinueTestView(item: item)
                        .navigationTitle("BREATHE-Smart")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden(true))
        {
            HStack{
                VStack(alignment:.leading){
                    Text(item.patient ?? DataVisUtils.defaultName)
                        .bold()
                    Text(item.room ?? DataVisUtils.defaultRoom)
                    Text("\(item.starttime ?? DataVisUtils.defaultTimestamp, formatter: dateformatter)")
                    Text("\(item.starttime ?? DataVisUtils.defaultTimestamp, formatter: timeformatter)")
                }
                Spacer()
                HStack{
                    if item.imageboardbefore != nil {
                        Text("In Progress")
                            .bold()
                            .font(.system(size:20))
                            .foregroundColor(.yellow)
                    } else {
                        Text("Ready")
                            .bold()
                            .font(.system(size:20))
                            .foregroundColor(.green)
                    }
                }
                .frame(width: 4*fontSize*1.3)
                .frame(maxHeight:.infinity)
                .background(Color("ButtonBackground"))
            }
        }
        .alert(isPresented: self.$showingDeleteAlert) {
            Alert(title: Text("Confirmation"), message: Text("Would you like to delete this test?"), primaryButton: .destructive(Text("Delete")) {
                for index in self.toBeDeleted! {
                    if let index_core = self.items.lastIndex(where: { $0.id == currentlyinprogress[index] }) {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.items[index_core].identifier!])
                        viewContext.delete(self.items[index_core])
                    }
                }
                do{
                    try viewContext.save()
                } catch let error {
                    print("Error: \(error)")
                }
                self.toBeDeleted = nil
                self.currentlyinprogress = []
            }, secondaryButton: .cancel() {
                self.toBeDeleted = nil
                self.currentlyinprogress = []
            })
        }
    }
}

