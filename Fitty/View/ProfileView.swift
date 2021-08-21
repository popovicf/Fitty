//
//  SettingsView.swift
//  Fitty
//
//  Created by Filip Popovic
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import LetterAvatarKit

struct ProfileView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var showingAlert = false
    var edges = UIApplication.shared.windows.first?.safeAreaInsets
    @StateObject var settingsData = SettingsViewModel()
    @State private var isPresented = true
    @State private var date: Date?
    @State var selectedIndexGender: Int? = nil
    @State var selectedIndexActivity: Int? = nil
    @State var selectedIndexCondition: Int? = nil
    let genderList = ["Male", "Female"]
    let previousActivityList = ["No fitness experience", "Occasional activity", "Amateur athlete", "Profesional athlete", "Ex athlete"]
    let physicalConditionList = ["One month without any activity", "No activity for last 3 months", "Inactive for about 6 months period", "2-3 times a week activity", "3-5 times a week activity", "Everyday activity"]
    
    var body: some View {
        VStack {
            HStack{
                Text("")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                
                Spacer(minLength: 0)
                
            }
            .padding()
            .padding(.top, edges?.top)
            .background(Color(UIColor.systemOrange))
            
            if settingsData.user.profile_picture != "" {
                ZStack{
                    
                    WebImage(url: URL(string: settingsData.user.profile_picture))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 125, height: 125)
                        .clipShape(Circle())
                    
                    if settingsData.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                    }
                }
                .padding(.top, 25)
                .onTapGesture {
                    settingsData.picker.toggle()
                }
            } else {
                let avatarImage = LetterAvatarMaker()
                    .setUsername(settingsData.user.full_name)
                    .build()
                ZStack{
                    Image(uiImage: avatarImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 125, height: 125)
                        .clipShape(Circle())
                    if settingsData.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                    }
                }
                .padding(.top, 25)
                .onTapGesture {
                    settingsData.picker.toggle()
                }
            }
            
            HStack(spacing: 15){
                Text(settingsData.user.full_name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Button(action: {settingsData.updateDetails(field: "name")}) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
            
            HStack(spacing: 15){
                Text(settingsData.user.email)
                    .foregroundColor(.white)
                
                Button(action: {settingsData.updateDetails(field: "email")}) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                .alert(isPresented: $showingAlert, content: {
                    Alert(title: Text("Important message"), message: Text(settingsData.error), dismissButton: .cancel(Text("Ok"), action: {
                        settingsData.logOut()
                        presentationMode.wrappedValue.dismiss()
                    }))
                })
            }
            .padding()
            
            Button(action: {
                settingsData.logOut()
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Log out")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 100)
                    .background(Color.blue)
                    .clipShape(Capsule())
                
            })
            .padding()
            .padding(.top, 10)
                        
            VStack {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 0) {
                        HStack(){
                            VStack(alignment: .leading) {
                                Text("Birth date: \(getDate())")
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
                                    .font(.system(size: 14))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(.orange)
                                    .frame(maxHeight: .infinity)
                            }
                            .frame(maxWidth: (UIScreen.main.bounds.size.width/2), maxHeight: .infinity, alignment: .leading)
                            .padding(.trailing)
                            
                            VStack() {
                                DatePickerTextField(placeholder: "Change date", date: self.$date)
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 14))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(.orange)
                                
                            }
                            .frame(maxWidth: (UIScreen.main.bounds.size.width/2), maxHeight: .infinity, alignment: .trailing)
                        }
                        .padding()
                        .padding(.horizontal)
                        .fixedSize(horizontal: false, vertical: true)
                        
                        HStack(){
                            VStack(alignment: .leading) {
                                Text("Gender: ")
                                    .font(.system(size: 14))
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.orange)
                                    .frame(maxHeight: .infinity)
                                
                            }
                            .frame(maxWidth: (UIScreen.main.bounds.size.width/2), maxHeight: .infinity, alignment: .leading)
                            .padding(.trailing)
                            
                            VStack() {
                                if settingsData.userInfo.gender != "" {
                                    PickerField(settingsData.userInfo.gender, data: self.genderList, selectionIndex: self.$selectedIndexGender)
                                        .lineLimit(nil)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 14))
                                        .fixedSize(horizontal: false, vertical: true)
                                        .foregroundColor(.orange)
                                } else {
                                    PickerField("Choose gender", data: self.genderList, selectionIndex: self.$selectedIndexGender)
                                        .lineLimit(nil)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 14))
                                        .fixedSize(horizontal: false, vertical: true)
                                        .foregroundColor(.orange)
                                }
                            }
                            .frame(maxWidth: (UIScreen.main.bounds.size.width/2), maxHeight: .infinity, alignment: .trailing)
                        }
                        .padding()
                        .padding(.horizontal)
                        .fixedSize(horizontal: false, vertical: true)
                        
                        HStack(spacing: 15){
                            VStack(alignment: .leading) {
                                Text("Physical condition: ")
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
                                    .font(.system(size: 14))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(.orange)
                                    .frame(maxHeight: .infinity)
                            }
                            .frame(maxWidth: (UIScreen.main.bounds.size.width/2), maxHeight: .infinity, alignment: .leading)
                            .padding(.trailing)
                            
                            VStack() {
                                if settingsData.userInfo.physicalCondition != "" {
                                    PickerField(settingsData.userInfo.physicalCondition, data: self.physicalConditionList, selectionIndex: self.$selectedIndexCondition)
                                        .lineLimit(nil)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 14))
                                        .fixedSize(horizontal: false, vertical: true)
                                        .foregroundColor(.orange)
                                } else {
                                    PickerField("Check your condition", data: self.physicalConditionList, selectionIndex: self.$selectedIndexCondition)
                                        .lineLimit(nil)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 14))
                                        .fixedSize(horizontal: false, vertical: true)
                                        .foregroundColor(.orange)
                                }
                            }
                            .frame(maxWidth: (UIScreen.main.bounds.size.width/2), maxHeight: .infinity, alignment: .trailing)
                        }
                        .padding()
                        .padding(.horizontal)
                        .fixedSize(horizontal: false, vertical: true)
                        
                        HStack(){
                            VStack(alignment: .leading) {
                                Text("Injuries: " + settingsData.userInfo.injuries)
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
                                    .font(.system(size: 14))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(.orange)
                                    .frame(maxHeight: .infinity)
                            }
                            .frame(maxWidth: (UIScreen.main.bounds.size.width/2), maxHeight: .infinity, alignment: .leading)
                            .padding(.trailing)
                            
                            VStack() {
                                Button(action: {settingsData.updateDetails(field: "injuries")}) {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.orange)
                                    
                                }
                            }
                            .frame(maxWidth: (UIScreen.main.bounds.size.width/2), maxHeight: .infinity, alignment: .center)
                        }
                        .padding()
                        .padding(.horizontal)
                        .fixedSize(horizontal: false, vertical: true)
                        
                        HStack(){
                            VStack(alignment: .leading) {
                                Text("Chronic diseases: " + settingsData.userInfo.chronicDiseases)
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
                                    .font(.system(size: 14))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(.orange)
                                    .frame(maxHeight: .infinity)
                            }
                            .frame(maxWidth: (UIScreen.main.bounds.size.width/2), maxHeight: .infinity, alignment: .leading)
                            .padding(.trailing)
                            
                            VStack() {
                                Button(action: {settingsData.updateDetails(field: "chronic diseases")}) {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.orange)
                                }
                            }
                            .frame(maxWidth: (UIScreen.main.bounds.size.width/2), maxHeight: .infinity, alignment: .center)
                        }
                        .padding()
                        .padding(.horizontal)
                        .fixedSize(horizontal: false, vertical: true)
                        
                        HStack() {
                            VStack(alignment: .leading) {
                                Text("Previous activity: ")
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
                                    .font(.system(size: 14))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(.orange)
                                    .frame(maxHeight: .infinity)
                            }
                            .frame(maxWidth: (UIScreen.main.bounds.size.width/2), maxHeight: .infinity, alignment: .leading)
                            .padding(.trailing)
                            
                            VStack() {
                                if settingsData.userInfo.previousActivity != "" {
                                    PickerField(settingsData.userInfo.previousActivity, data: self.previousActivityList, selectionIndex: self.$selectedIndexActivity)
                                        .lineLimit(nil)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 14))
                                        .fixedSize(horizontal: false, vertical: true)
                                        .foregroundColor(.orange)
                                } else {
                                    PickerField("Check activity", data: self.previousActivityList, selectionIndex: self.$selectedIndexActivity)
                                        .lineLimit(nil)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 14))
                                        .fixedSize(horizontal: false, vertical: true)
                                        .foregroundColor(.orange)
                                }
                            }
                            .frame(maxWidth: (UIScreen.main.bounds.size.width/2), maxHeight: .infinity, alignment: .trailing)
                        }
                        .padding()
                        .padding(.horizontal)
                        .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    .background(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                    .cornerRadius(50)
                }
                .shadow(radius: 25)
            }
            .padding(.bottom, 0)
            .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.size.height, alignment: .center)
        }
        .sheet(isPresented: $settingsData.picker) {
            ImagePicker(picker: $settingsData.picker, img_Data: $settingsData.img_data )
        }
        .onChange(of: settingsData.img_data) { (newData) in
            settingsData.updateImage()
        }
        .onChange(of: settingsData.user.full_name) { value in
            ChatService.updateExistingChat(with: User.current, key: "title")
        }
        .onChange(of: settingsData.error) { value in
            showingAlert = true
        }
    }
    
    func getDate() -> String {
        let timestamp = (settingsData.userInfo.birthDate)?.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "MM/dd/YYYY"
        let date = formatter.string(from: timestamp!)
        return date
    }
    
}
