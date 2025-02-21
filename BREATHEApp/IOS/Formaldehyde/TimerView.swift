import SwiftUI

struct TimerView: View{
    @Environment(\.managedObjectContext) private var viewContext
    private var item: TestData = TestData()
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var timeremaining: Int
    @State private var timershow: Int
    @State private var start: Int
    
    init(item: TestData){
        self.item = item
        let now = Int(Date().timeIntervalSince1970)
        let start = Int(item.starttime!.timeIntervalSince1970)
        var timeremaining = 30 - (now - start)
        if timeremaining <= 0 {
            timeremaining = (now - start) - 30
        }
        self.start = start
        self.timeremaining = timeremaining
        self.timershow = timeremaining
    }
    
    var body: some View{
            HStack{
                Text(self.formatString(timershow))
                    .fontWeight(.bold)
                    .font(.system(size:20, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("ButtonForeground"))
                if  timeremaining < 0 {
                    Text("Passed")
                        .fontWeight(.bold)
                        .font(.system(size:20))
                        .foregroundColor(Color("ButtonForeground"))
                } else {
                    Text("Remaining")
                        .fontWeight(.bold)
                        .font(.system(size:20))
                        .foregroundColor(Color("ButtonForeground"))
                }
            }
            .padding(50)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color("ButtonBackground")))
            .onReceive(timer) { time in
                let now = Int(Date().timeIntervalSince1970)
                timeremaining = 30 - (now - start)
                timershow = timeremaining
                if timeremaining <= 0 {
                    timershow = -timershow
                }
            }
    }
    func formatString(_ secs:Int) -> String{
        let h = secs/3600
        let m = (secs-h*3600)/60
        let s = secs%60
        return String(format: "%02d:%02d:%02d",h,m,s)
    }
}

struct NewTimerView: View{
    
    @ObservedObject var newTestData: NewTestData
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var timeremaining: Int = 0
    var body: some View{
            HStack{
                Text(self.formatString(timeremaining))
                    .fontWeight(.bold)
                    .font(.system(size:20, design: .monospaced))
                    .foregroundColor(Color("ButtonForeground"))
                if newTestData.timeremaining < 0 {
                    Text("Passed")
                        .fontWeight(.bold)
                        .font(.system(size:20))
                        .foregroundColor(Color("ButtonForeground"))
                } else {
                    Text("Remaining")
                        .fontWeight(.bold)
                        .font(.system(size:20))
                        .foregroundColor(Color("ButtonForeground"))
                }
            }
            .padding(50)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color("ButtonBackground")))
            .onReceive(timer) { time in
                let now = Int(Date().timeIntervalSince1970)
                let start = Int(newTestData.starttime.timeIntervalSince1970)
                newTestData.timeremaining = 30 - (now - start)
                if newTestData.timeremaining <= 0 {
                    timeremaining = -newTestData.timeremaining
                } else {
                    timeremaining = newTestData.timeremaining
                }
            }
    }
    func formatString(_ secs:Int) -> String{
        let h = secs/3600
        let m = (secs-h*3600)/60
        let s = secs%60
        return String(format: "%02d:%02d:%02d",h,m,s)
    }
}

struct ContinueTimerView: View{
    
    @ObservedObject var continueTestData: ContinueTestData
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var timeremaining: Int = 0
    var body: some View{
            HStack{
                Text(self.formatString(timeremaining))
                    .fontWeight(.bold)
                    .font(.system(size:20, design: .monospaced))
                    .foregroundColor(Color("ButtonForeground"))
                if continueTestData.timeremaining < 0 {
                    Text("Passed")
                        .fontWeight(.bold)
                        .font(.system(size:20))
                        .foregroundColor(Color("ButtonForeground"))
                } else {
                    Text("Remaining")
                        .fontWeight(.bold)
                        .font(.system(size:20))
                        .foregroundColor(Color("ButtonForeground"))
                }
            }
            .padding(50)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color("ButtonBackground")))
            .onReceive(timer) { time in
                let now = Int(Date().timeIntervalSince1970)
                let start = Int(continueTestData.starttime.timeIntervalSince1970)
                continueTestData.timeremaining = 30 - (now - start)
                if continueTestData.timeremaining <= 0 {
                    timeremaining = -continueTestData.timeremaining
                } else {
                    timeremaining = continueTestData.timeremaining
                }
            }
    }
    func formatString(_ secs:Int) -> String{
        let h = secs/3600
        let m = (secs-h*3600)/60
        let s = secs%60
        return String(format: "%02d:%02d:%02d",h,m,s)
    }
}
