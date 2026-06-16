////
////  RoleSelectionView.swift
////  Bakery
////
////  Created by Narges nurani on 2026.06.16.
////
//
//
//struct RoleSelectionView: View {
//    @ObservedObject var viewModel: AppViewModel
//    @Environment(\.dismiss) var dismiss
//    @State private var selectedRole: String?
//    
//    var body: some View {
//        ZStack {
//            Color.brown.ignoresSafeArea()
//            VStack(spacing: 30) {
//                // دکمه بازگشت
//                HStack {
//                    Button(action: { dismiss() }) {
//                        Image(systemName: "arrow.backward.circle.fill")
//                            .font(.largeTitle)
//                            .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
//                    }
//                    Spacer()
//                    Spacer()
//                    Spacer()
//                    
//                    
//                }
//                .padding(.horizontal)
//                Spacer()
//                Text("نقش خود را انتخاب کنید.")
//                    .font(.system(size: 32, weight: .bold, design: .default))
//                    .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.9))
//                Spacer()
//                
//                NavigationLink(destination: BakerView(viewModel: viewModel)) {
//                    RoleButton(title: "نانوا", icon: "🥖")
//                }
//                
//                NavigationLink(destination: CustomerView(viewModel: viewModel)) {
//                    RoleButton(title: "مشتری", icon: "🛒")
//                }
//                
//                NavigationLink(destination: DeliveryView(viewModel: viewModel)) {
//                    RoleButton(title: "پیک", icon: "🛵")
//                }
//                Spacer()
//                
//                Spacer()
//                Spacer()
//                
//            }
//            .padding()
//        }
//        .navigationBarHidden(true)
//    }
//}
//
//struct RoleButton: View {
//    let title: String
//    let icon: String
//    
//    var body: some View {
//        ZStack {
//            Capsule()
//                .frame(width: 250, height: 80)
//                .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.9))
//                .shadow(color: .white.opacity(0.5), radius: 5)
//            HStack {
//                Text(icon)
//                    .font(.largeTitle)
//                Text(title)
//                    .font(.system(size: 25, weight: .semibold, design: .rounded))
//                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
//            }
//        }
//    }
//}
