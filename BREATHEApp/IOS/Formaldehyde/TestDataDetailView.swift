import SwiftUI
import CoreData

class DataVisUtils{
    
    static var defaultName = "Anonymous"
    static var defaultRoom = "Unknown"
    static var defaultTimestamp = Date(timeIntervalSinceReferenceDate: 0)
    
    static func colorize(_ value: Float) -> Color{
        if value < 0.3{
            return Color("ReadingLow")
        }else if value>0.7 {
            return Color("ReadingHigh")
        }else{
            return Color("ReadingMedium")
        }
    }
    static func formatReading(_ value: Float) -> String{
        if value<0.02
        {
            return "<0.02"
        }else{
            return String(format:"%.2f", value)
        }
    }
}

struct DetailedListItem: View{
    private var title: String = ""
    private var abbr: String = ""
    private var reading: Float = 0
    
    init(title: String, abbr: String, reading: Float)
    {
        self.title = title
        self.abbr = abbr
        self.reading = reading
    }
    
    var body: some View
    {
        HStack{
            VStack(alignment:.trailing){
                Text(title)
                    .bold()
                    .font(.system(size: 23))
                HStack{
                    Spacer()
                    Text("(")
                        .bold()
                        .font(.title)
                    
                    Text(abbr)
                        .bold()
                        .font(.title)
                        .foregroundColor(DataVisUtils.colorize(reading))
                    
                    Text(")")
                        .bold()
                        .font(.title)
                }
            }.frame(width:150)
            Spacer()
            HStack{
                Text(DataVisUtils.formatReading(reading))
                    .foregroundColor(.black)
                    .bold()
                    .font(.largeTitle)
                    .frame(width:100)
                Rectangle()
                    .frame(width: 70, height: 100)
                    .foregroundColor(DataVisUtils.colorize(reading))
            }.background(Color("ButtonBackground"))
        }
    }
}

struct TestDataDetailView: View{
    @Environment(\.presentationMode) var presentationMode
    @State private var showActionSheet: Bool = false
    @EnvironmentObject private var viewRouter: ViewRouter
    
    private var item: TestData? = nil
    
    let dateformatter = DateFormatter()
    
    init(){
        dateformatter.dateFormat = "MMMM dd, yyyy. hh:mm a"
    }
    
    init(item: TestData?){
        self.item = item
        dateformatter.dateFormat = "MMMM dd, yyyy. hh:mm a"
    }
    
    var body: some View{
        if let item = item {
            VStack {
                HStack(alignment: .bottom){
                    Text("\(item.room ?? DataVisUtils.defaultRoom)")
                        .font(.headline)
                    Text("\(item.starttime ?? DataVisUtils.defaultTimestamp, formatter: dateformatter)")
                }
                .foregroundColor(.black)
                .frame(maxWidth:.infinity)
                .background(Color("ButtonBackground"))
                
                Spacer()
                List{
                    DetailedListItem(title: "Formaldehyde", abbr: "F", reading: item.reading_formaldehyde)
                }
                
                bottomBar.frame(height: 82)
            }
            .navigationBarItems(leading: btnBack, trailing: helpbutton)
        }else{
            VStack{
                Spacer()
                Text("Test Data Not Found.")
                    .bold()
                    .font(.largeTitle)
                Spacer()
            }
            .navigationBarItems(leading: btnBack)
        }
    }
    @ViewBuilder
    var btnBack : some View {
        if viewRouter.currentView != .main && viewRouter.currentView != .startnewtest{
            Button(action: {
            self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.black)
                }
        } else { EmptyView() }
    }
    
    var helpbutton : some View {
        NavigationLink(destination:
            helpView().navigationTitle("Help").navigationBarTitleDisplayMode(.inline).navigationBarBackButtonHidden(true))
        {
            Text("Help")
                .foregroundColor(.black)
        }
    }
    
    var bottomBar: some View {
        ZStack{
            Rectangle()
                .foregroundColor(Color("TabBarBackground"))
            
            Button(action: {
                showActionSheet = true
            }){
                Text("S H A R E    R E S U L T S")
                    .bold()
                    .font(.title2)
                    .padding()
                    .foregroundColor(Color("ButtonForeground")).frame(minWidth: 250)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color("ButtonBackground")))
            }.actionSheet(isPresented: $showActionSheet)
            {
                ActionSheet(
                    title: Text("Share your test results or return to the main screen!"),
                    message: Text(""),
                    buttons: [.default(Text("EMAIL")) { },
                              .default(Text("RETURN HOME")) { returnHomePressed() },
                              .default(Text("DISMISS")){ }]
                )
            }
        }
    }
    func returnHomePressed()
    {
        if viewRouter.currentView == .main {
            viewRouter.currentView = .archive
        }else{
            viewRouter.currentView = .main
        }
    }
}

struct helpView: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View{
        VStack(alignment: .leading){
            HStack{
                Text("Explain My Results")
                    .bold()
                    .font(.title)
                    .padding()
                Spacer()
            }
            VStack(alignment: .leading){
                HStack{
                    Rectangle()
                        .foregroundColor(Color("ReadingHigh"))
                        .frame(width: 20, height: 20)
                    Text("RED = HIGH (greater than 0.69)")
                }
                Text("This level of allergen has been observed to trigger symptoms in most children or adults who suffer from asthma or allergies.")
                HStack{
                    Rectangle()
                        .foregroundColor(Color("ReadingMedium"))
                        .frame(width: 20, height: 20)
                    Text("Yellow = MODERATE (0.30-0.69)")
                }
                Text("This level of allergen has been observed to trigger symptoms in some children or adults who suffer from asthma or allergies.")
                HStack{
                    Rectangle()
                        .foregroundColor(Color("ReadingLow"))
                        .frame(width: 20, height: 20)
                    Text("GREEN = LOW OR NON-DETECTABLE (0.0-0.29) ")
                }
                Text("This level corresponds to a very low allergen presence which is not expected to cause symptoms in most individuals.  However, some sensitive individuals may still experience symptoms.")
                Spacer()
            }
            .padding(.horizontal, 30)
        }
        .navigationBarItems(leading: btnBack)
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
}
