////
////  DeliveryView.swift
////  Bakery
////
////  Created by Narges nurani on 2026.06.16.
////
//
//
//struct DeliveryView: View {
//    @ObservedObject var viewModel: AppViewModel
//    @State private var assignedOrder: Order?
//    
//    var pendingOrders: [Order] {
//        viewModel.bakerOrders.filter { $0.status == .pending }
//    }
//    
//    var deliveringOrders: [Order] {
//        viewModel.bakerOrders.filter { $0.status == .onDelivery }
//    }
//    
//    var body: some View {
//        ZStack {
//            Color(red: 0.75, green: 0.65, blue: 0.5).ignoresSafeArea()
//            VStack {
//                Text("پیک")
//                    .font(.system(size: 40, weight: .bold, design: .rounded))
//                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
//                    .padding(.top, 30)
//                
//                // سفارشات در حال ارسال
//                if !deliveringOrders.isEmpty {
//                    Text("سفارشات در حال ارسال")
//                        .font(.title2)
//                        .bold()
//                    ForEach(deliveringOrders) { order in
//                        OrderCard(order: order) {
//                            viewModel.completeDelivery(order: order)
//                        }
//                        .environment(\.layoutDirection, .rightToLeft)
//                    }
//                }
//                
//                // سفارشات آماده
//                if !pendingOrders.isEmpty {
//                    Text("سفارشات آماده برای پیک")
//                        .font(.title2)
//                        .bold()
//                        .padding(.top)
//                    ForEach(pendingOrders) { order in
//                        OrderCard(order: order) {
//                            _ = viewModel.assignOrderToDelivery(order: order)
//                        }
//                        .environment(\.layoutDirection, .rightToLeft)
//                    }
//                }
//                
//                if pendingOrders.isEmpty && deliveringOrders.isEmpty {
//                    Text("هیچ سفارشی موجود نیست")
//                        .font(.title3)
//                        .foregroundColor(.gray)
//                        .padding()
//                }
//                
//                Spacer()
//            }
//        }
//    }
//}
