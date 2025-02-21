import SwiftUI

struct AboutView: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View{
        VStack {
            List{
                NavigationLink(destination: Formaldehyde().navigationTitle("BREATHE-Smart").navigationBarTitleDisplayMode(.inline).navigationBarBackButtonHidden(true))
                {
                    createEntry(title: "About Formaldehyde", desc: "Learn about this indoor contaminant")
                }
                NavigationLink(destination: TextView2().navigationTitle("BREATHE-Smart").navigationBarTitleDisplayMode(.inline).navigationBarBackButtonHidden(true))
                {
                    createEntry(title: "About BREATHE - Smart", desc: "Learn more about our project")
                }
                NavigationLink(destination: TextView3().navigationTitle("BREATHE-Smart").navigationBarTitleDisplayMode(.inline).navigationBarBackButtonHidden(true))
                {
                    createEntry(title: "Contact & Contributors", desc: "Project personnel")
                }
            }
            Spacer()
            TabView([
                TabBarItem(image: Image("BreatheIcon_ag"), title: "Home"),
                TabBarItem(image: Image("SafeIcon_ag"), title: "Archive"),
                TabBarItem(image: Image("info icon"), title: "Info"),
            ]).frame(height: 80)
        }
    }

    func createEntry(title:String, desc: String) -> some View {
        ZStack(alignment: .leading){
            RoundedRectangle(cornerRadius: 20)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color("ButtonBackground"))
            
            VStack(alignment: .leading){
                Text(title)
                    .bold()
                    .font(.title)
                    .foregroundColor(.black)
                Text(desc)
                    .foregroundColor(.black)
            }.padding()
        }
    }
}

struct Formaldehyde: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View{
        VStack(alignment: .leading){
            HStack{
                Text("About Formaldehyde")
                    .bold()
                    .font(.title)
                    .padding()
                Spacer()
            }
            Text("Detail")
                .font(.body)
                .padding(.horizontal,30)
            Spacer()
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

struct TextView2: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View{
        VStack(alignment: .leading){
            HStack{
                Text("BREATHE-Smart")
                    .bold()
                    .font(.title)
                    .padding()
                Spacer()
            }
            Text("Detail")
                .font(.body)
                .padding(.horizontal,30)
            Spacer()
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

struct TextView3: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View{
        
        VStack(alignment: .leading){
            HStack{
                Text("Contact & Contributors")
                    .bold()
                    .font(.title)
                    .padding()
                Spacer()
            }
            Text("Detail")
                .font(.body)
                .padding(.horizontal,30)
            Spacer()
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

struct AboutView_Previews: PreviewProvider {
    static var previews: some View
    {
        AboutView()
    }
}
