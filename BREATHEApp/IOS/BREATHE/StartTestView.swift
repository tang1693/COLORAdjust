//
//  StartTestView.swift
//  BREATHE
//
//  Created by Shaun Song on 2021/4/20.
//  Modified by Guixiang Zhang on 2021/6/25.
//

import SwiftUI

struct TimeoutView: View{
    let TIMEOUT: Int = 600
    @State private var timeRemaining: Int = 5
    @State private var isTakenPhotoEnable: Bool = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View{
        VStack{
            Spacer()
            
            VStack{
                Spacer()
                Text("Your test is ready!")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("ButtonForeground"))
                Spacer()
                    .frame(height:32)
                Text("Press the button\n below to take a photo")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("ButtonForeground"))
                Spacer()
                    .frame(height:32)
                Group{Text("Note").bold()+Text(": you will have only \(formatString(timeRemaining)) minutes to complete your analysis.")}
                    .font(.body)
                    .multilineTextAlignment(.center)
                Spacer()
            }.padding(32)
            
            Spacer()
            
            bottomBar.frame(height: 90)
            
        }.onReceive(timer) { time in
            if timeRemaining > 0 {
                timeRemaining -= 1
            }else{
                isTakenPhotoEnable = false
            }
        }.onAppear(perform:{
            timeRemaining = TIMEOUT
        })
    }
    
    var bottomBar: some View{
        ZStack{
            Rectangle()
                .foregroundColor(Color("TabBarBackground"))
            NavigationLink(destination: CameraSnapshotView()
                            .navigationTitle("BREATHE-Smart")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarBackButtonHidden(true)){
                Text("T A K E    P H O T O")
                    .bold()
                    .font(.title2)
                    .padding()
                    .foregroundColor(Color("ButtonForeground")).frame(minWidth: 250)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color("ButtonBackground")))
                    .disabled(isTakenPhotoEnable)
            }
        }
    }
    
    func formatString(_ secs:Int) -> String{
        let m = secs/60
        let s = secs%60
        return String(format: "%02d:%02d", m, s)
    }
}

struct TimerView: View{
    let TIMEOUT: Int = 5
    @State private var timeRemaining: Int = 5
    @State private var selection: Int? = nil
    
    var buttonEnable = true // Please set to false in release mode
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View{
        VStack{
            Spacer()
            
            VStack{
                Text(self.formatString(self.timeRemaining))
                    .fontWeight(.bold)
                    .font(.system(size:90, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("ButtonForeground"))
                Text("Remaining")
                    .fontWeight(.bold)
                    .font(.system(size:40))
                    .multilineTextAlignment(.center)
                    .padding(16)
                    .foregroundColor(Color("ButtonForeground"))
            }.padding(32)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color("ButtonBackground")))
            .padding(16)
            
            Spacer()
            
            NavigationLink(
                destination:TimeoutView().navigationBarBackButtonHidden(true).navigationTitle("BREATHE-Smart").navigationBarTitleDisplayMode(.inline)
                , tag:0, selection: $selection){ EmptyView() }
            
            bottomBar.frame(height: 90)
            
        }.onReceive(timer) { time in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            }else{
                self.selection = 0
            }
            
        }.onAppear(perform:{
            self.timeRemaining = TIMEOUT
        })
    }
    
    var bottomBar: some View{
        Button(action:{
            self.selection=0
        })
        {
            Rectangle()
                .foregroundColor(Color("TabBarBackground"))
        }.disabled(!self.buttonEnable)
    }
    
    func formatString(_ secs:Int) -> String{
        let m = secs/60
        let s = secs%60
        return String(format: "%02d:%02d", m, s)
    }
}

struct StartTestView: View{
    var body: some View
    {
        VStack{
            Spacer()
            Text("Time to collect your sample!\n\nOnce your sample has been prepared, click the START button below and insert the sensor into the solution.\n\nClicking the button below will start a 5-minute timer.")
                .font(.title2)
                .foregroundColor(Color.black)
                .multilineTextAlignment(.center)
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color("TextBackground")))
                .padding(16)
            
            Spacer()
            bottomBar.frame(height: 90)
        }
    }
    var bottomBar: some View{
        ZStack{
            Rectangle()
                .foregroundColor(Color("TabBarBackground"))
            
            NavigationLink(destination: TimerView()
                            .navigationTitle("BREATHE-Smart")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarBackButtonHidden(true))
            {
                Text("S T A R T").bold().font(.title2).padding()
                    .foregroundColor(Color("ButtonForeground")).frame(minWidth: 250)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color("ButtonBackground")))
            }
        }
    }
}


struct StartTestiew_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            StartTestView()
        }
    }
}

