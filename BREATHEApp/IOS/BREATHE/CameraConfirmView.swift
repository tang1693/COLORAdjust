//
//  CameraConfirmView.swift
//  BREATHE
//
//  Created by Shaun Song on 2021/4/26.
//  Modified by Guixiang Zhang on 2021/6/25.
//

import SwiftUI

class NewTestData: ObservableObject
{
    @Published var item: TestData? = nil
}

struct CameraConfirmView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var patient: String = ""
    @State private var room: String = ""
    @State private var temp: String = ""
    @State private var timestamp: Date = Date()
    @State private var isTestDataReady: Bool = false
    @State private var showTempDialog: Bool = false
    
    @StateObject var newTestData: NewTestData = NewTestData()
    
    var imageFrame: UIImage
    var imageBoard: UIImage
    
    init(){
        self.imageFrame = UIImage(systemName: "multiply.circle")!
        self.imageBoard = UIImage(systemName: "multiply.circle")!
    }
    
    init(frame: UIImage, board: UIImage, timestamp: Date)
    {
        self.imageFrame = frame.copy() as! UIImage
        self.imageBoard = board.copy() as! UIImage
        self.timestamp = timestamp
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
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
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
                Image(uiImage: imageBoard)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width:300, height:geometry.size.height*0.5)
                Spacer()
                
                bottomBar.frame(height: 90)
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
                // Create record
                let item = TestData(context: viewContext)
                item.id = UUID().uuidString
                item.patient = patient
                item.room = room
                item.tempature = temp
                item.imageBoard = self.imageBoard.jpegData(compressionQuality: 1)
                item.timestamp = timestamp
                
                // TODO: get readings from board
                item.reading_cockroach = Float.random(in: 0..<1)
                item.reading_mouse = Float.random(in: 0..<1)
                item.reading_dustmite1 = Float.random(in: 0..<1)
                item.reading_dustmite2 = Float.random(in: 0..<1)
                
                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
                self.newTestData.item = item
                isTestDataReady.toggle()
            }){
                Text("N E X T")
                    .bold()
                    .font(.title2)
                    .padding()
                    .foregroundColor(Color("ButtonForeground")).frame(minWidth: 250)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color("ButtonBackground")))
            }
        }
    }
}

struct CameraConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        CameraConfirmView()
    }
}
