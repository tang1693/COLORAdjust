import SwiftUI

class NewTestData: ObservableObject
{
    @Published var item : TestData = TestData()
    @Published var imageBoardBefore : UIImage? = nil
    @Published var imageBoardAfter : UIImage? = nil
    @Published var imageFrameBefore : UIImage? = nil
    @Published var imageFrameAfter : UIImage? = nil
    @Published var starttime : Date = Date()
    @Published var timeremaining: Int = 0
    @Published var imagesaved: Bool = false
    @Published var identifier: String = UUID().uuidString
}

struct NewTestView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var viewRouter: ViewRouter
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var patient: String = ""
    @State private var room: String = ""
    @State private var temp: String = ""
    @State private var isTestDataReady: Bool = false
    @State private var isTestPause: Bool = false
    @State private var showTempDialog: Bool = false
    @State private var disableAfter: Bool = true
    @StateObject var newTestData: NewTestData = NewTestData()
    @State private var item: TestData? = nil
    let dateformatter = DateFormatter()
    @State private var time: String = ""
    
    @ViewBuilder
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
    
    @ViewBuilder
    private var before: some View {
        GeometryReader { geometry in
            if newTestData.imageBoardBefore != nil {
                Image(uiImage: newTestData.imageBoardBefore!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            else{
                Text("Tap to take BEFORE image")
                    .bold()
                    .font(.system(size: 25))
                    .foregroundColor(.black)
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            }
        }
    }
    
    @ViewBuilder
    private var after: some View {
        GeometryReader { geometry in
            if newTestData.imageBoardAfter != nil {
                Image(uiImage: newTestData.imageBoardAfter!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            else{
                Text("Tap to take AFTER image")
                    .bold()
                    .font(.system(size: 25))
                    .foregroundColor(.black)
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                Spacer()
                HStack{
                    NavigationLink(destination:
                                    CameraSnapshotView(newTestData: newTestData, flag : true)
                                    .navigationTitle("BREATHE-Smart")
                                    .navigationBarTitleDisplayMode(.inline)
                                    .navigationBarBackButtonHidden(true)
                    ) {
                        before
                    }.background(RoundedRectangle(cornerRadius: 20).fill(Color("ButtonBackground")))
                    .aspectRatio(3/2, contentMode: .fit)
                    Spacer()
                    NavigationLink(destination:
                                    CameraSnapshotView(newTestData: newTestData, flag : false)
                                    .navigationTitle("BREATHE-Smart")
                                    .navigationBarTitleDisplayMode(.inline)
                                    .navigationBarBackButtonHidden(true)
                    ) {
                        after
                    }
                    .disabled(disableAfter)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color("ButtonBackground")))
                    .aspectRatio(3/2, contentMode: .fit)
                }
                Spacer()
                VStack{
                    HStack {
                        Text("Patient:")
                            .foregroundColor(Color.black)
                            .frame(width: 80)
                            .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                            .background(Color("ButtonBackground"))
                        TextField("Fill patient name here", text: $patient)
                            .foregroundColor(.black)
                    }
                    HStack{
                        Text("Room:")
                            .foregroundColor(Color.black)
                            .frame(width: 80)
                            .multilineTextAlignment(.leading)
                            .background(Color("ButtonBackground"))
                        TextField("Fill room here", text: $room)
                            .foregroundColor(.black)
                    }
                    HStack{
                        Text("Temp:")
                            .foregroundColor(Color.black)
                            .frame(width: 80)
                            .multilineTextAlignment(.leading)
                        TextField("Please select temperature", text: $temp)
                            .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.black)
                            .background(Color("ButtonBackground"))
                            .onTapGesture(perform: {
                                self.showTempDialog = true
                            }).actionSheet(isPresented: $showTempDialog) {
                                ActionSheet(
                                    title: Text("Temperature"),
                                    message: Text("Select the temperature of the room"),
                                    buttons: [.default(Text("Over 80° F")) { self.temp = "Over 80° F"},
                                              .default(Text("65-80° F")) { self.temp="65-80° F"},
                                              .default(Text("Under 65° F")) { self.temp="Under 65° F"}]
                                )
                            }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color("ButtonBackground")))
                .padding()
                Spacer()
                if newTestData.imageBoardBefore != nil{
                    NewTimerView(newTestData: newTestData)
                    if newTestData.imageBoardAfter != nil{
                        bottomBar.frame(height: 82)
                    } else {
                        UpdateProgressBar.frame(height: 82)
                    }
                } else {
                    SaveReadyBar.frame(height: 82)
                }
            }
        }
        .onAppear{
            dateformatter.dateFormat = "MMMM dd, yyyy. hh:mm a"
            if newTestData.imageBoardBefore != nil {
                disableAfter = false
                if self.item == nil{
                    let item = TestData(context: viewContext)
                    item.id = UUID().uuidString
                    item.patient = patient
                    item.room = room
                    item.tempature = temp
                    item.starttime = newTestData.starttime
                    item.identifier = newTestData.identifier
                    item.imageboardbefore = newTestData.imageBoardBefore!.jpegData(compressionQuality: 1)
                    item.imageframebefore = newTestData.imageFrameBefore!.jpegData(compressionQuality: 1)
                    item.inprogress = true
                    item.ready = false
                    do {
                        try viewContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                    self.item = item
                    let content = UNMutableNotificationContent()
                    self.time = dateformatter.string(from: item.starttime!)
                    content.title = "Take AFTER Image"
                    content.subtitle = "Test start: \(self.time)"
                    content.sound = UNNotificationSound.default
                    // show this notification ten seconds from now
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
                    // choose a random identifier
                    let request = UNNotificationRequest(identifier: self.item!.identifier!, content: content, trigger: trigger)
                    // add our notification request
                    UNUserNotificationCenter.current().add(request)
                }
            }
        }
        .navigationBarItems(leading: btnBack)
    }
    
    var bottomBar: some View {
        ZStack{
            Rectangle()
                .foregroundColor(Color("TabBarBackground"))
            NavigationLink(destination:
                            TestDataDetailView(item: newTestData.item)
                            .navigationTitle("BREATHE-Smart")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarBackButtonHidden(true)
                           , isActive: $isTestDataReady){
            EmptyView()}
            Button(action: {
                self.item!.patient = patient
                self.item!.room = room
                self.item!.tempature = temp
                self.item!.starttime = newTestData.starttime
                self.item!.identifier = newTestData.identifier
                self.item!.imageboardbefore = newTestData.imageBoardBefore!.jpegData(compressionQuality: 1)
                self.item!.imageframebefore = newTestData.imageFrameBefore!.jpegData(compressionQuality: 1)
                self.item!.imageboardafter = newTestData.imageBoardAfter!.jpegData(compressionQuality: 1)
                self.item!.imageframeafter = newTestData.imageFrameAfter!.jpegData(compressionQuality: 1)
                self.item!.inprogress = false
                self.item!.ready = false
                self.item!.reading_formaldehyde = Float.random(in: 0..<1)
                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
                self.newTestData.item = self.item!
                isTestDataReady.toggle()
            }){
                Text("RESULT")
                    .bold()
                    .font(.title2)
                    .padding()
                    .foregroundColor(Color("ButtonForeground")).frame(minWidth: 250)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color("ButtonBackground")))
            }
        }
    }
    
    var SaveReadyBar: some View {
        ZStack{
            Rectangle()
                .foregroundColor(Color("TabBarBackground"))
            NavigationLink(destination:
                            HomeView(sortDescripter: NSSortDescriptor(keyPath: \TestData.id, ascending: false))
                            .navigationTitle("BREATHE-Smart")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarBackButtonHidden(true)
                           , isActive: $isTestPause){
            EmptyView()}
            Button(action: {
                let item = TestData(context: viewContext)
                item.id = UUID().uuidString
                item.patient = patient
                item.room = room
                item.tempature = temp
                item.starttime = newTestData.starttime
                item.identifier = newTestData.identifier
                item.inprogress = false
                item.ready = true
                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
                viewRouter.currentView = .main
                isTestPause.toggle()
            }){
                Text("S A V E")
                    .bold()
                    .font(.title2)
                    .padding()
                    .foregroundColor(Color("ButtonForeground")).frame(minWidth: 250)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color("ButtonBackground")))
            }
        }
    }
    
    var UpdateProgressBar: some View {
        ZStack{
            Rectangle()
                .foregroundColor(Color("TabBarBackground"))
            NavigationLink(destination:
                            HomeView(sortDescripter: NSSortDescriptor(keyPath: \TestData.id, ascending: false))
                            .navigationTitle("BREATHE-Smart")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarBackButtonHidden(true)
                           , isActive: $isTestPause){
            EmptyView()}
            Button(action: {
                self.item!.patient = patient
                self.item!.room = room
                self.item!.tempature = temp
                self.item!.starttime = newTestData.starttime
                self.item!.identifier = newTestData.identifier
                self.item!.imageboardbefore = newTestData.imageBoardBefore!.jpegData(compressionQuality: 1)
                self.item!.imageframebefore = newTestData.imageFrameBefore!.jpegData(compressionQuality: 1)
                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
                let now = Int(Date().timeIntervalSince1970)
                let start = Int(newTestData.starttime.timeIntervalSince1970)
                let interval = Double(30 - (now - start))
                let content = UNMutableNotificationContent()
                self.time = dateformatter.string(from: self.item!.starttime!)
                content.title = "Take AFTER Image"
                content.subtitle = "Test start: \(self.time)"
                content.sound = UNNotificationSound.default
                // show this notification ten seconds from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
                // choose a random identifier
                let request = UNNotificationRequest(identifier: self.item!.identifier!, content: content, trigger: trigger)
                // add our notification request
                UNUserNotificationCenter.current().add(request)
                
                viewRouter.currentView = .main
                isTestPause.toggle()
            }){
                Text("UPDATE")
                    .bold()
                    .font(.title2)
                    .padding()
                    .foregroundColor(Color("ButtonForeground")).frame(minWidth: 250)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color("ButtonBackground")))
            }
        }
    }
}


