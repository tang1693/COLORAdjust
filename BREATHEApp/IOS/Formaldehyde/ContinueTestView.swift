import SwiftUI

class ContinueTestData: ObservableObject
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

struct ContinueTestView: View {
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
    private var item: TestData = TestData()
    @StateObject var continueTestData: ContinueTestData = ContinueTestData()
    let dateformatter = DateFormatter()
    @State private var time: String = ""
    
    init(item: TestData){
        self.item = item
        dateformatter.dateFormat = "MMMM dd, yyyy. hh:mm a"
    }
    
    @ViewBuilder
    var btnBack : some View {
        NavigationLink(
            destination: HomeView(sortDescripter: NSSortDescriptor(keyPath: \TestData.id, ascending: false))
                        .navigationTitle("BREATHE-Smart")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden(true))
        {
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
            if continueTestData.imageBoardBefore != nil {
                    Image(uiImage: continueTestData.imageBoardBefore!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
            } else if item.imageboardbefore != nil {
                Image(uiImage: UIImage(data: item.imageboardbefore!)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
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
            if continueTestData.imageBoardAfter != nil {
                Image(uiImage: continueTestData.imageBoardAfter!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if item.imageboardafter != nil {
                Image(uiImage: UIImage(data: item.imageboardafter!)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
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
                                    CameraSnapshotView_cont(continueTestData: self.continueTestData, flag : true)
                                    .navigationTitle("BREATHE-Smart")
                                    .navigationBarTitleDisplayMode(.inline)
                                    .navigationBarBackButtonHidden(true)
                    ) {
                        before
                    }.background(RoundedRectangle(cornerRadius: 20).fill(Color("ButtonBackground")))
                    .aspectRatio(3/2, contentMode: .fit)
                    Spacer()
                    NavigationLink(destination:
                                    CameraSnapshotView_cont(continueTestData: self.continueTestData, flag : false)
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
                if continueTestData.imageBoardBefore != nil {
                    ContinueTimerView(continueTestData: continueTestData)
                } else if self.item.imageboardbefore != nil{
                    TimerView(item: self.item)
                }
                if continueTestData.imageBoardAfter != nil {
                    bottomBar.frame(height: 82)
                }
                else {
                    updateBar.frame(height: 82)
                }
            }
        }.onAppear{
            dateformatter.dateFormat = "MMMM dd, yyyy. hh:mm a"
            self.patient = item.patient ?? ""
            self.room = item.room ?? ""
            self.temp = item.tempature ?? ""
            if item.ready == true {
                if continueTestData.imageBoardBefore != nil {
                    disableAfter = false
                    if patient != ""{
                        item.patient = patient
                    }
                    if room != ""{
                        item.room = room
                    }
                    if temp != ""{
                        item.tempature = temp
                    }
                    item.starttime = continueTestData.starttime
                    item.identifier = continueTestData.identifier
                    item.imageboardbefore = continueTestData.imageBoardBefore!.jpegData(compressionQuality: 1)
                    item.imageframebefore = continueTestData.imageFrameBefore!.jpegData(compressionQuality: 1)
                    item.inprogress = true
                    item.ready = false
                    do {
                        try viewContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                    let content = UNMutableNotificationContent()
                    self.time = dateformatter.string(from: item.starttime!)
                    content.title = "Take AFTER Image"
                    content.subtitle = "Test start: \(self.time)"
                    content.sound = UNNotificationSound.default
                    // show this notification ten seconds from now
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
                    // choose a random identifier
                    let request = UNNotificationRequest(identifier: self.item.identifier!, content: content, trigger: trigger)
                    // add our notification request
                    UNUserNotificationCenter.current().add(request)
                }
            } else {
                if item.imageboardbefore != nil {
                    disableAfter = false
                }
            }
        }.navigationBarItems(leading: btnBack)
    }

    var bottomBar: some View {
        ZStack{
            Rectangle()
                .foregroundColor(Color("TabBarBackground"))
            NavigationLink(destination:
                            TestDataDetailView(item: item)
                            .navigationTitle("BREATHE-Smart")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarBackButtonHidden(true)
                           , isActive: $isTestDataReady){
            EmptyView()}
            Button(action: {
                if patient != ""{
                    item.patient = patient
                }
                if room != ""{
                    item.room = room
                }
                if temp != ""{
                    item.tempature = temp
                }
                if continueTestData.imageBoardBefore != nil{
                    item.starttime = continueTestData.starttime
                    item.imageboardbefore = continueTestData.imageBoardBefore!.jpegData(compressionQuality: 1)
                    item.imageframebefore = continueTestData.imageFrameBefore!.jpegData(compressionQuality: 1)
                }
                item.imageboardafter = continueTestData.imageBoardAfter!.jpegData(compressionQuality: 1)
                item.imageframeafter = continueTestData.imageFrameAfter!.jpegData(compressionQuality: 1)
                item.inprogress = false
                item.ready = false
                item.reading_formaldehyde = Float.random(in: 0..<1)
                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
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
    
    var updateBar: some View {
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
                if patient != ""{
                    item.patient = patient
                }
                if room != ""{
                    item.room = room
                }
                if temp != ""{
                    item.tempature = temp
                }
                if continueTestData.imageBoardBefore != nil{
                    item.starttime = continueTestData.starttime
                    item.imageboardbefore = continueTestData.imageBoardBefore!.jpegData(compressionQuality: 1)
                    item.imageframebefore = continueTestData.imageFrameBefore!.jpegData(compressionQuality: 1)
                    let now = Int(Date().timeIntervalSince1970)
                    let start = Int(continueTestData.starttime.timeIntervalSince1970)
                    let interval = Double(30 - (now - start))
                    self.time = dateformatter.string(from: self.item.starttime!)
                    let content = UNMutableNotificationContent()
                    content.title = "Take AFTER Image"
                    content.subtitle = "Test start: \(self.time)"
                    content.sound = UNNotificationSound.default
                    // show this notification ten seconds from now
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
                    // choose a random identifier
                    let request = UNNotificationRequest(identifier: self.item.identifier!, content: content, trigger: trigger)
                    // add our notification request
                    UNUserNotificationCenter.current().add(request)
                    item.inprogress = true
                    item.ready = false
                }
                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
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
