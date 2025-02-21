import SwiftUI
import CoreData

struct TrashListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest var items: FetchedResults<TestData>
    @Binding var searchText: String
    
    let fontSize: CGFloat = 32
    let dateformatter = DateFormatter()
    let timeformatter = DateFormatter()
    @State private var toBeDeleted: IndexSet? = nil
    @State private var showingDeleteAlert: Bool = false
    @State private var currentNotTrashID: [String] = []
    
    @State private var showAllAlert: Bool = false
    @State private var showAlert: Bool = false
    @State var isEditing = false
    @State var selections = Set<TestData>()
    
    init(searchText: Binding<String>, sortDescripter: NSSortDescriptor) {
        self._searchText = searchText
        let request: NSFetchRequest<TestData> = TestData.fetchRequest()
        request.sortDescriptors = [sortDescripter]
        _items = FetchRequest<TestData>(fetchRequest: request)
        
        dateformatter.dateFormat = "MMMM dd, yyyy"
        timeformatter.dateFormat = "hh:mm a"
    }
    var body: some View {
        VStack{
            HStack{
                editButton
                RecoverButton.padding(.horizontal)
                DelButton
            }
            List(selection: $selections) {
                ForEach(items.filter({ (searchText.isEmpty ? true : $0.patient!.lowercased().contains(searchText.lowercased())) && $0.intrash && (!$0.inprogress) && (!$0.ready) }), id: \.self) { item in
                    if self.isEditing{
                        self.datawithoutlink(for: item)
                    } else {
                        self.datawithlink(for: item)
                    }
                }
                .onDelete(perform: deleteItems)
            }
        }
    }
    
    private func datawithoutlink(for item: TestData) -> some View{
        HStack{
            if self.isEditing{
                Image(systemName: self.selections.contains(item) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(self.selections.contains(item) ? Color.blue : Color.gray)
                    .font(.system(size: 24))
            }
            VStack(alignment:.leading){
                Text(item.patient ?? DataVisUtils.defaultName)
                    .bold()
                Text(item.room ?? DataVisUtils.defaultRoom)
                Text("\(item.starttime ?? DataVisUtils.defaultTimestamp, formatter: dateformatter)")
                Text("\(item.starttime ?? DataVisUtils.defaultTimestamp, formatter: timeformatter)")
            }
            Spacer()
            HStack{
                Text("Formaldehyde")
                    .bold()
                    .font(.system(size:20))
                    .foregroundColor(DataVisUtils.colorize(item.reading_formaldehyde))
            }
            .frame(width: 4*fontSize*1.3)
            .frame(maxHeight:.infinity)
            .background(Color("ButtonBackground"))
        }
        .alert(isPresented: self.$showingDeleteAlert) {
            Alert(title: Text("Confirmation"), message: Text("Would you like to permanently delete this record? You will not be able to recover it."), primaryButton: .destructive(Text("Delete")) {
                for index in self.toBeDeleted! {
                    if let index_core = self.items.lastIndex(where: { $0.id == currentNotTrashID[index] }) {
                        viewContext.delete(self.items[index_core])
                    }
                }
                do{
                    try viewContext.save()
                } catch let error {
                    print("Error: \(error)")
                }
                self.toBeDeleted = nil
                self.currentNotTrashID = []
            }, secondaryButton: .cancel() {
                self.toBeDeleted = nil
                self.currentNotTrashID = []
            })
        }
        .onTapGesture{
            if self.selections.contains(item) {
                self.selections.remove(item)
            } else {
                self.selections.insert(item)
            }
        }
        .listRowBackground(self.selections.contains(item) ? Color.gray : Color.white)
    }
    
    private func datawithlink(for item: TestData) -> some View{
        NavigationLink(destination: TestDataDetailView(item: item)
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
                        Text("Formaldehyde")
                            .bold()
                            .font(.system(size:20))
                            .foregroundColor(DataVisUtils.colorize(item.reading_formaldehyde))
                    }
                    .frame(width: 4*fontSize*1.3)
                    .frame(maxHeight:.infinity)
                    .background(Color("ButtonBackground"))
                }
        }
        .alert(isPresented: self.$showingDeleteAlert) {
            Alert(title: Text("Confirmation"), message: Text("Would you like to permanently delete this record? You will not be able to recover it."), primaryButton: .destructive(Text("Delete")) {
                for index in self.toBeDeleted! {
                    if let index_core = self.items.lastIndex(where: { $0.id == currentNotTrashID[index] }) {
                        viewContext.delete(self.items[index_core])
                    }
                }
                do{
                    try viewContext.save()
                } catch let error {
                    print("Error: \(error)")
                }
                self.toBeDeleted = nil
                self.currentNotTrashID = []
            }, secondaryButton: .cancel() {
                self.toBeDeleted = nil
                self.currentNotTrashID = []
            })
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        self.toBeDeleted = offsets
        self.showingDeleteAlert = true
        for item in (items.filter({ (searchText.isEmpty ? true : $0.patient!.lowercased().contains(searchText.lowercased())) && $0.intrash && (!$0.inprogress) && (!$0.ready) })) {
            self.currentNotTrashID.append(item.id!)
        }
    }
    
    private var editButton: some View {
        Button(action: {
            self.isEditing.toggle()
            self.selections = Set<TestData>()
        }) {
            Text(self.isEditing ? "Done" : "Select")
        }
    }
    
    @ViewBuilder
    private var RecoverButton: some View {
        if !self.isEditing {
            Button(action: {
                for _ in items {
                    if let index = self.items.lastIndex(where: { $0.intrash == true }) {
                        self.items[index].intrash = false
                    }
                    do {
                        try viewContext.save()
                    } catch let error {
                        print("Error: \(error)")
                    }
                }
            }) {
                Text("Recover All")
            }
        } else {
            Button(action: {
                for id in self.selections {
                    if let index = self.items.lastIndex(where: { $0.id == id.id }) {
                        self.items[index].intrash = false
                    }
                    self.selections = Set<TestData>()
                    self.isEditing = false
                    do {
                        try viewContext.save()
                    } catch let error {
                        print("Error: \(error)")
                    }
                }
            }) {
                Text("Recover")
            }
        }
    }
    
    @ViewBuilder
    private var DelButton: some View {
        if !self.isEditing {
            Button(action: {
                self.showAllAlert = true
            }) {
                Text("Delete All")
            }
            .alert(isPresented: $showAllAlert) {
                Alert(title: Text("Confirmation"), message: Text("Would you like to permanently delete all records in the trash? You will not able to recover it."), primaryButton: .destructive(Text("Delete")) {
                    for _ in items {
                        if let index = self.items.lastIndex(where: { $0.intrash == true }) {
                            viewContext.delete(self.items[index])
                        }
                        do {
                            try viewContext.save()
                        } catch let error {
                            print("Error: \(error)")
                        }
                    }
                }, secondaryButton: .cancel() {
                    self.showAllAlert = false
                })
            }
        } else {
            Button(action: {
                self.showAlert = true
            }) {
                Text("Delete")
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Confirmation"), message: Text("Would you like to permanently delete these \(self.selections.count) records? You will not be able to recover them."), primaryButton: .destructive(Text("Delete")) {
                    for id in self.selections {
                        if let index = self.items.lastIndex(where: { $0.id == id.id }) {
                            viewContext.delete(self.items[index])
                        }
                        do {
                            try viewContext.save()
                        } catch let error {
                            print("Error: \(error)")
                        }
                    }
                    self.selections = Set<TestData>()
                    self.isEditing = false
                }, secondaryButton: .cancel() {
                    self.selections = Set<TestData>()
                    self.isEditing = false
                })
            }
        }
    }
}

struct TrashView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var searchText: String = ""
    @State private var sortType: Int = 0
    @State private var sortAsc: Bool = false
    
    @State var showMenuItem1 = false
    @State var showMenuItem2 = false
    @State var showMenuItem3 = false
    @State var showMenuItem4 = false
    
    var sortDesc: NSSortDescriptor {
        switch sortType {
        case 0:
            return NSSortDescriptor(keyPath: \TestData.patient, ascending: sortAsc)
        case 1:
            return NSSortDescriptor(keyPath: \TestData.starttime, ascending: sortAsc)
        case 2:
            return NSSortDescriptor(keyPath: \TestData.reading_formaldehyde, ascending: sortAsc)
        default:
            return NSSortDescriptor(keyPath: \TestData.id, ascending: false)
        }
    }
    var btnBack : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .foregroundColor(.black)
        }
    }
    
    private func showMenu() {
        self.showMenuItem1.toggle()
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack{
                VStack {
                    HStack{
                        // Name
                        Button(action: {
                                if sortType == 0 {sortAsc.toggle()}
                                else{sortType = 0}})
                        {
                            Text("Name")
                            if sortType==0 {Image(systemName: sortAsc ? "chevron.up" : "chevron.down").foregroundColor(.black)}
                        }
                        .frame(width: geometry.size.width/3.1, height: geometry.size.height/10)
                        .foregroundColor(Color("ButtonForeground"))
                        .background(Color("ButtonBackground"))
                        // Date
                        Button(action: {
                                if sortType == 1 {sortAsc.toggle()}
                                else{sortType = 1}}){
                            Text("Date")
                            if sortType==1 {Image(systemName: sortAsc ? "chevron.up" : "chevron.down").foregroundColor(.black)}
                        }
                        .frame(width: geometry.size.width/3.1, height: geometry.size.height/10)
                        .foregroundColor(Color("ButtonForeground"))
                        .background(Color("ButtonBackground"))
                        Spacer()
                        
                    }
                    Spacer()
                    SearchBar(text: $searchText)
                    TrashListView(searchText: $searchText, sortDescripter: sortDesc)
                    TabView([
                        TabBarItem(image: Image("BreatheIcon_ag"), title: "Home"),
                        TabBarItem(image: Image("SafeIcon_ag"), title: "Archive"),
                        TabBarItem(image: Image("info icon"), title: "Info"),
                    ]).frame(height: 80)
                }
                Button(action: {
                        self.showMenu()
                }) {
                    Text("Test Results")
                        .frame(width: geometry.size.width/3.1, height: geometry.size.height/10)
                        .foregroundColor(Color("ButtonForeground"))
                        .background(Color("ButtonBackground"))
                }.position(x: geometry.size.width/3*2.55, y: geometry.size.height/20)
                if showMenuItem1 {
                    // Formaldehyde
                    Button(action: {
                            if sortType == 2 {sortAsc.toggle()}
                            else{sortType = 2}}){
                        Text("Formaldehyde")
                        if sortType==2 {Image(systemName: sortAsc ? "chevron.up" : "chevron.down").foregroundColor(.black)}
                    }
                    .frame(width: geometry.size.width/3.1, height: geometry.size.height/10)
                    .foregroundColor(Color("ButtonForeground"))
                    .background(Color("ButtonBackground"))
                    .position(x: geometry.size.width/3*2.55,y: geometry.size.height/20*3)
                }
            }
            .navigationBarItems(leading: btnBack)
        }
    }
}

