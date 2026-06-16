//
//  SignUpView.swift
//  Bakery
//
//  Created by Narges nurani on 2026.06.16.
//


// MARK: - SignUpView (همان طراحی شما)
//
//struct SignUpView: View {
//    @State private var email = ""
//    @State private var password = ""
//    @StateObject private var viewModel = AppViewModel()
//    @State private var isLoggedIn = false
//    @Environment(\.dismiss) var dismiss
//    
//    var body: some View {
//        ZStack {
//            Color(red: 0.75, green: 0.65, blue: 0.5).ignoresSafeArea()
//            Capsule()
//                .frame(width: 400, height: 600)
//                .padding(25)
//                .foregroundColor(.brown)
//                .shadow(color: .white, radius: 10)
//            VStack {
//                Spacer(minLength: 200)
//                Label("ثبت نام", systemImage: "")
//                    .bold()
//                    .font(.system(size: 50, weight: .medium, design: .rounded))
//                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
//                
//                ZStack {
//                    Capsule()
//                        .frame(width: 350, height: 90)
//                        .padding(25)
//                        .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.9))
//                        .shadow(color: .brown, radius: 10)
//                    TextField("ایمیل", text: $email)
//                        .font(.system(size: 20, weight: .medium, design: .rounded))
//                        .padding(.leading, 70)
//                }
//                ZStack {
//                    Capsule()
//                        .frame(width: 350, height: 90)
//                        .padding(25)
//                        .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.9))
//                        .shadow(color: .brown, radius: 10)
//                    SecureField("رمز عبور", text: $password)
//                        .font(.system(size: 20, weight: .medium, design: .rounded))
//                        .padding(.leading, 70)
//                }
//                
//                Button(action: { isLoggedIn = true }) {
//                    ZStack {
//                        Capsule()
//                            .frame(width: 90, height: 90)
//                            .padding(25)
//                            .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
//                            .shadow(color: .brown, radius: 10)
//                        Text("ثبت نام")
//                            .font(.system(size: 20, weight: .medium, design: .rounded))
//                            .foregroundColor(Color(red: 0.88, green: 0.90, blue: 0.88))
//                    }
//                    
//                }
//             
//                Spacer(minLength: 210)
//            }
//            Spacer(minLength: 200)
//        }
//        
//        .fullScreenCover(isPresented: $isLoggedIn) {
//            NavigationView {
//                RoleSelectionView(viewModel: viewModel)
//            }
//       
//        }
//      
//    }
//}
//    
