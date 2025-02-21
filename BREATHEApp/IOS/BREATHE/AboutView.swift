//
//  AboutView.swift
//  BREATHE
//
//  Created by Shaun Song on 2021/5/2.
//  Modified by Guixiang Zhang on 2021/6/24.
//

import SwiftUI

struct AboutView: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View{
        VStack {
            List{
                NavigationLink(destination: TextView1().navigationTitle("BREATHE-Smart").navigationBarTitleDisplayMode(.inline).navigationBarBackButtonHidden(true))
                {
                    createEntry(title: "About Allergens", desc: "Description Text")
                }
                NavigationLink(destination: TextView2().navigationTitle("BREATHE-Smart").navigationBarTitleDisplayMode(.inline).navigationBarBackButtonHidden(true))
                {
                    createEntry(title: "About BREATHE - Smart", desc: "Description Text")
                }
                NavigationLink(destination: TextView3().navigationTitle("BREATHE-Smart").navigationBarTitleDisplayMode(.inline).navigationBarBackButtonHidden(true))
                {
                    createEntry(title: "Contact & Contributors", desc: "Description Text")
                }
            }
            Spacer()
            TabView([
                TabBarItem(image: Image("BreatheIcon_ag"), title: "Home"),
                TabBarItem(image: Image("SafeIcon_ag"), title: "Archive"),
                TabBarItem(image: Image("info icon"), title: "Info"),
            ]).frame(height: 90)
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

struct TextView1: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View{
        VStack(alignment: .leading){
            HStack{
                Text("General")
                    .bold()
                    .font(.title)
                    .padding()
                Spacer()
            }
            ScrollView{
                Text("Allergens are foreign substances that may trigger a reaction, or allergic inflammatory response1, by the immune system of an affected individual. Because allergens are not pathogens2, the response is an overreaction by the immune system to something that does not normally cause harm. Common allergens include plant pollens, dust mites, mold spores, animal dander (including mice and rats), cockroaches, foods, medications and the secretions or venom from biting or stinging insects. On a microscopic level, the proteins from these substances often resemble the proteins found in pathogens, which fools the body’s immune system into producing a reaction. The response is akin to mistaken identity by one’s immune system.\nPeople whose immune systems respond to allergens suffer from allergies. Allergy sufferers are often sensitive to multiple substances. Common symptoms to allergies are runny nose, itching, wheezing and coughing.  The wheezing and coughing may be a sign of asthma.  In the US, about XX% of people suffer from allergies and XX% suffer from asthma.\n1.inflammatory response—a series of early and late phase events carried out by one’s immune system in response to disease or injury. The events include a release of agents such as immune cells, antibodies and signal molecules that are designed to neutralize harmful foreign substances and promote healing. These agents may produce mucus secretions (runny nose), bronchial or muscle spasm (asthma, anaphylaxis), itching, redness and swelling.\n2.pathogen- a microorganism such as a virus, bacterium or fungus that has the potential to cause disease. Examples include cold viruses and infectious bacteria, like the E. coli O15H7 strain. In some people whose immune systems are not functioning properly, microorganisms which are normally harmless may also cause disease. ")
                    .font(.body)
                    .padding(.horizontal,30)
            }
            Spacer()
            VStack{
                NavigationLink(destination: Cockroach().navigationTitle("BREATHE-Smart").navigationBarTitleDisplayMode(.inline).navigationBarBackButtonHidden(true))
                {
                    createEntry(title: "About Cockroach", desc: "")
                }.frame(height: 60)
                NavigationLink(destination: Mouse().navigationTitle("BREATHE-Smart").navigationBarTitleDisplayMode(.inline).navigationBarBackButtonHidden(true))
                {
                    createEntry(title: "About Mouse", desc: "")
                }.frame(height: 60)
                NavigationLink(destination: Dust().navigationTitle("BREATHE-Smart").navigationBarTitleDisplayMode(.inline).navigationBarBackButtonHidden(true))
                {
                    createEntry(title: "About Dust", desc: "")
                }.frame(height: 60)
            }.frame(height: 190)
        }.navigationBarItems(leading: btnBack)
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
    func createEntry(title:String, desc: String) -> some View {
        ZStack(alignment: .leading){
            RoundedRectangle(cornerRadius: 30)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color("ButtonBackground"))
            
            VStack(alignment: .leading){
                Text(title)
                    .bold()
                    .font(.title)
                    .foregroundColor(.black)
                if desc != "" {
                    Text(desc)
                        .foregroundColor(.black)
                }
            }.padding()
        }
    }
}

struct Cockroach: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View{
        VStack(alignment: .leading){
            HStack{
                Text("About Cockroach")
                    .bold()
                    .font(.title)
                    .padding()
                Spacer()
            }
            ScrollView{
                Text("Detail")
                    .font(.body)
                    .padding(.horizontal,30)
            }
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

struct Mouse: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View{
        VStack(alignment: .leading){
            HStack{
                Text("About Mouse")
                    .bold()
                    .font(.title)
                    .padding()
                Spacer()
            }
            ScrollView{
                Text("Detail")
                    .font(.body)
                    .padding(.horizontal,30)
            }
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

struct Dust: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View{
        VStack(alignment: .leading){
            HStack{
                Text("About Dust")
                    .bold()
                    .font(.title)
                    .padding()
                Spacer()
            }
            ScrollView{
                Text("Detail")
                    .font(.body)
                    .padding(.horizontal,30)
            }
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
            ScrollView{
                Text("Detail")
                    .font(.body)
                    .padding(.horizontal,30)
            }
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
                Text("Contact")
                    .bold()
                    .font(.title)
                    .padding()
                Spacer()
            }
            ScrollView{
                Text("If you are experiencing a medical emergency, please call 911.  For all medical questions or concerns, please contact Dr. Christopher Timan at Nationwide Children’s Hospital at (614) 722-4526. If you have any questions about this application or your results, please contact Dr. Karen Dannemiller at The Ohio State University at (614) 292-4031.\nThis work was completed with funding from the US Department of Housing and Urban Development, HUD by a multidisciplinary team of investigators and contributors from public and private academic institutions and industry. The study was led by Dr. Karen Dannemiller (dannemiller.70@osu.edu), and the clinical team at NCH was led by Dr. Christopher Timan (christopher.timan@nationwidechildrens.org).")
                    .font(.body)
                    .padding(.horizontal,30)
            }
            NavigationLink(destination: ContributerView().navigationTitle("BREATHE-Smart").navigationBarTitleDisplayMode(.inline).navigationBarBackButtonHidden(true))
            {
                createEntry(title: "Contributors", desc: "")
            }.frame(height: 60)
        }
        .navigationBarItems(leading: btnBack)
    }
    func createEntry(title:String, desc: String) -> some View {
        ZStack(alignment: .leading){
            RoundedRectangle(cornerRadius: 30)
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

struct ContributerView: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View{
        VStack(alignment: .leading){
            HStack{
                Text("Leader")
                    .bold()
                    .font(.title)
                    .padding()
                Spacer()
            }
            Text("Karen Dannemiller, PhD, (OSU) – Principal Investigator, leader of the study and the filed team, primary role in statistical analyses.")
                .font(.body)
                .padding(.horizontal,30)
            NavigationLink(destination: FieldTeam().navigationTitle("BREATHE-Smart").navigationBarTitleDisplayMode(.inline).navigationBarBackButtonHidden(true))
            {
                createEntry(title: "Field Team", desc: "")
            }.frame(height: 60)
            NavigationLink(destination: AppTeam().navigationTitle("BREATHE-Smart").navigationBarTitleDisplayMode(.inline).navigationBarBackButtonHidden(true))
            {
                createEntry(title: "App Team", desc: "")
            }.frame(height: 60)
            NavigationLink(destination: SensorTeam().navigationTitle("BREATHE-Smart").navigationBarTitleDisplayMode(.inline).navigationBarBackButtonHidden(true))
            {
                createEntry(title: "Sensor Team", desc: "")
            }.frame(height: 60)
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
    func createEntry(title:String, desc: String) -> some View {
        ZStack(alignment: .leading){
            RoundedRectangle(cornerRadius: 30)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color("ButtonBackground"))
            
            VStack(alignment: .leading){
                Text(title)
                    .bold()
                    .font(.title)
                    .foregroundColor(.black)
                if desc != "" {
                    Text(desc)
                        .foregroundColor(.black)
                }
            }.padding()
        }
    }
}

struct FieldTeam: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View{
        VStack(alignment: .leading){
            HStack{
                Text("Field Team")
                    .bold()
                    .font(.title)
                    .padding()
                Spacer()
            }
            ScrollView{
                Text("Jenny Panescu, MS (OSU) – data collection and management, badge test validation, assisted in study coordination.\n\nMatthew Perzanowski, PhD, (Columbia University) – co-investigator, study design, surveys for needs assessment and field validation, statistical analysis\n\nChristopher Timan, MD, (NCH) – co-investigator, coordinated recruitment of study participants and IRB\n\nPaul Seese, MSN, RN (NCH) – co-investigator, coordinated recruitment of study participants\n\nBailey Young, DO (NCH) – needs assessment and field validation\n\nNursing Staff at NCH – feeback on usability ")
                    .font(.body)
                    .padding(.horizontal,30)
            }
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

struct AppTeam: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View{
        VStack(alignment: .leading){
            HStack{
                Text("App Team")
                    .bold()
                    .font(.title)
                    .padding()
                Spacer()
            }
            ScrollView{
                Text("Rongjun Qin, PhD (OSU) – led code and app development\n\nNicholas Shapiro, PhD (UCLA) - app usability and app development\n\nShaun Song, MS (OSU) – code and app development\n\nGuixiang Zhang, BS (OSU) – code and app development\n\nAmisha ?")
                    .font(.body)
                    .padding(.horizontal,30)
            }
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
struct SensorTeam: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View{
        VStack(alignment: .leading){
            HStack{
                Text("Sensor Team")
                    .bold()
                    .font(.title)
                    .padding()
                Spacer()
            }
            ScrollView{
                Text("Perena Gouma, PhD OSU) – co-investigator, badge development\n\nMartin Chapman, PhD ( Indoor Biotechnologies) - vendor and industry consultant for the badge test\n\nFateh Mikaeili, MS (OSU) – sensor development\n\nEthan Hessick (OSU) – sensor development")
                    .font(.body)
                    .padding(.horizontal,30)
            }
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
