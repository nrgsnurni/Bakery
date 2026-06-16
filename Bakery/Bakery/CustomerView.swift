////
////  CustomerView.swift
////  Bakery
////
////  Created by Narges nurani on 2026.06.16.
////
//
//
//struct CustomerView: View {
//    @ObservedObject var viewModel: AppViewModel
//    @State private var selectedBakery: Bakery?
//    @State private var customerName = ""
//    @State private var orderItems: [Bread] = [
//        Bread(name: "بربری", count: 0),
//        Bread(name: "تافتون", count: 0),
//        Bread(name: "سنگک", count: 0)
//    ]
//    @State private var showConfirmation = false
//    
//    var body: some View {
//        ZStack {
//            Color(red: 0.75, green: 0.65, blue: 0.5).ignoresSafeArea()
//            VStack(spacing: 15) {
//                Text("سفارش نان")
//                    .font(.system(size: 40, weight: .bold, design: .rounded))
//                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
//                    .padding(.top, 30)
//                
//                // انتخاب نانوایی
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack {
//                        ForEach(viewModel.bakeries) { bakery in
//                            Button(action: { selectedBakery = bakery }) {
//                                VStack {
//                                    Text(bakery.name)
//                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
//                                    Text(bakery.address)
//                                        .font(.system(size: 12))
//                                }
//                                .padding()
//                                .background(selectedBakery?.id == bakery.id ? Color.brown : Color(red: 0.98, green: 0.98, blue: 0.9))
//                                .foregroundColor(selectedBakery?.id == bakery.id ? .white : .black)
//                                .cornerRadius(20)
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                
//                TextField("نام خود را وارد کنید", text: $customerName)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
//                    .font(.system(size: 18, design: .rounded))
//                
//                // سفارش نان‌ها
//                ForEach($orderItems) { $item in
//                    HStack {
//                        Text(item.name)
//                            .frame(width: 80)
//                        Stepper("\(item.count) عدد", value: $item.count, in: 0...20)
//                            .frame(width: 150)
//                    }
//                    .padding(.horizontal)
//                    .font(.system(size: 18, design: .rounded))
//                }
//                
//                Button(action: {
//                    if !customerName.isEmpty, let bakery = selectedBakery {
//                        let nonZeroItems = orderItems.filter { $0.count > 0 }
//                        if !nonZeroItems.isEmpty {
//                            viewModel.placeOrder(bakeryName: bakery.name, customerName: customerName, items: nonZeroItems)
//                            showConfirmation = true
//                            // ریست فرم
//                            customerName = ""
//                            for i in 0..<orderItems.count { orderItems[i].count = 0 }
//                            selectedBakery = nil
//                        }
//                    }
//                }) {
//                    ZStack {
//                        Capsule()
//                            .frame(width: 200, height: 60)
//                            .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
//                        Text("ثبت سفارش")
//                            .font(.system(size: 22, weight: .semibold, design: .rounded))
//                            .foregroundColor(Color(red: 0.88, green: 0.90, blue: 0.88))
//                    }
//                }
//                .padding(.top)
//                
//                Spacer()
//            }
//        }
//        .alert("سفارش ثبت شد", isPresented: $showConfirmation) {
//            Button("باشه", role: .cancel) { }
//        }
//    }
//}
