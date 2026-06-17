//
//  ContentView.swift
//  Aura Tasks
//
//  Created by Narges nurani on 2026.03.21.
//

import SwiftUI
import Combine
import SwiftData

// MARK: - مدل داده‌ها

// مدل نان
struct Bread: Identifiable, Equatable {
    let id = UUID()
    let name: String // نام نان (بربری، تافتون، سنگک)
    var count: Int    // تعداد
}

// مدل سفارش
struct Order: Identifiable {
    let id = UUID()
    let bakeryName: String
    let customerName: String
    let items: [Bread]
    var status: OrderStatus = .pending
}

// وضعیت سفارش
enum OrderStatus: String {
    case pending = "در انتظار پیک"
    case onDelivery = "در حال ارسال"
    case delivered = "تحویل شده"
}

// مدل نانوایی
struct Bakery: Identifiable {
    let id = UUID()
    let name: String
    let address: String
}

// MARK: - ViewModel اصلی (مدیریت وضعیت اپ)

class AppViewModel: ObservableObject {
    @Published var bakerOrders: [Order] = []      // سفارشات دریافتی نانوا
    @Published var customerOrders: [Order] = []   // سفارشات ثبت شده توسط مشتری
    @Published var bakerBreadStock: [Bread] = [   // موجودی نانوا
        Bread(name: "بربری", count: 0),
        Bread(name: "تافتون", count: 0),
        Bread(name: "سنگک", count: 0)
    ]
    
    let bakeries = [
        Bakery(name: "نانوایی برکت", address: "خیابان امام، نبش کوچه ۵"),
        Bakery(name: "نانوایی سنگک سنتی", address: "میدان آزادی، پلاک ۱۲"),
        Bakery(name: "نانوایی تافتون پارس", address: "بلوار دانشگاه، بعد از پمپ بنزین")
    ]
    // تنظیم موجودی اولیه
       func setInitialStock(
           barbari: Int,
           taftoon: Int,
           sangak: Int
       ) {
           bakerBreadStock = [
               Bread(name: "بربری", count: barbari),
               Bread(name: "تافتون", count: taftoon),
               Bread(name: "سنگک", count: sangak)
           ]
       }
    // نانوا: اضافه کردن نان
    func addBread(_ breadName: String) {
        if let index = bakerBreadStock.firstIndex(where: { $0.name == breadName }) {
            bakerBreadStock[index].count += 1
        }
    }
    
    // نانوا: حذف نان
    func removeBread(_ breadName: String) {
        if let index = bakerBreadStock.firstIndex(where: { $0.name == breadName }), bakerBreadStock[index].count > 0 {
            bakerBreadStock[index].count -= 1
        }
    }
    
    // مشتری: ثبت سفارش جدید
    func placeOrder(bakeryName: String, customerName: String, items: [Bread]) {
        let newOrder = Order(bakeryName: bakeryName, customerName: customerName, items: items)
        customerOrders.append(newOrder)
        bakerOrders.append(newOrder) // سفارش برای نانوا هم ارسال می‌شه
    }
    
    // پیک: گرفتن سفارش
    func assignOrderToDelivery(order: Order) -> Order {
        var updatedOrder = order
        updatedOrder.status = .onDelivery
        // آپدیت در هر دو لیست
        if let index = bakerOrders.firstIndex(where: { $0.id == order.id }) {
            bakerOrders[index].status = .onDelivery
        }
        if let index = customerOrders.firstIndex(where: { $0.id == order.id }) {
            customerOrders[index].status = .onDelivery
        }
        return updatedOrder
    }
    
    // پیک: تحویل سفارش
    func completeDelivery(order: Order) {
        if let index = bakerOrders.firstIndex(where: { $0.id == order.id }) {
            bakerOrders[index].status = .delivered
        }
        if let index = customerOrders.firstIndex(where: { $0.id == order.id }) {
            customerOrders[index].status = .delivered
        }
    }
}

// MARK: - صفحه اصلی ورود (همان طراحی شما)

struct WelcomeView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @StateObject private var viewModel = AppViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.brown.ignoresSafeArea()
                Capsule()
                    .frame(width: 400, height: 600)
                    .padding(25)
                    .foregroundColor(Color(red: 0.75, green: 0.65, blue: 0.5))
                    .shadow(color: .white, radius: 10)
                VStack {
                    Spacer(minLength: 200)
                    ZStack {
                        Label("ورود 🥖 " ,systemImage: "")
                            .bold()
                            .font(.system(size: 50, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                    }
                    ZStack {
                        Capsule()
                            .frame(width: 350, height: 90)
                            .padding(25)
                            .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.9))
                            .shadow(color: .brown, radius: 10)
                        TextField("نام کاربری", text: $email)
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(email.isEmpty ? .gray : .black)
                            .autocapitalization(.none)
                            .padding(.leading, 70)
                    }
                    ZStack {
                        Capsule()
                            .frame(width: 350, height: 90)
                            .padding(25)
                            .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.9))
                            .shadow(color: .brown, radius: 10)
                        SecureField("رمز عبور", text: $password)
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(email.isEmpty ? .gray : .black)
                            .autocapitalization(.none)
                            .padding(.leading, 70)
                    }
                    HStack {
                        NavigationLink(destination: SignUpView()) {
                            ZStack {
                                Capsule()
                                    .frame(width: 90, height: 90)
                                    .padding(25)
                                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                                    .shadow(color: .brown, radius: 10)
                                Text("ثبت‌نام")
                                    .font(.system(size: 20, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0.88, green: 0.90, blue: 0.88))
                            }
                        }
                        Button(action: { isLoggedIn = true }) {
                            ZStack {
                                Capsule()
                                    .frame(width: 90, height: 90)
                                    .padding(25)
                                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                                    .shadow(color: .brown, radius: 10)
                                Text("ورود")
                                    .font(.system(size: 20, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0.88, green: 0.90, blue: 0.88))
                            }
                        }
                    }
                    Spacer(minLength: 200)
                }
            }
      
                    .fullScreenCover(isPresented: $isLoggedIn) {
                        MainDashboardView(viewModel: viewModel)
                    }                }
            }
        }
    

// MARK: - انتخاب نقش (نانوا، مشتری، پیک)

struct RoleSelectionView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedRole: String?
    
    var body: some View {
        ZStack {
            Color.brown.ignoresSafeArea()
            VStack(spacing: 30) {
                // دکمه بازگشت
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.backward.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    
                }
                .padding(.horizontal)
                Spacer()
                Text("نقش خود را انتخاب کنید.")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.9))
                Spacer()
                
                NavigationLink(destination: BakerView(viewModel: viewModel)) {
                    RoleButton(title: "نانوا", icon: "🥖")
                }
                
                NavigationLink(destination: CustomerView(viewModel: viewModel)) {
                    RoleButton(title: "مشتری", icon: "🛒")
                }
                
                NavigationLink(destination: DeliveryView(viewModel: viewModel)) {
                    RoleButton(title: "پیک", icon: "🛵")
                }
                Spacer()
                
                Spacer()
                Spacer()
                
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}

struct RoleButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        ZStack {
            Capsule()
                .frame(width: 250, height: 80)
                .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.9))
                .shadow(color: .white.opacity(0.5), radius: 5)
            HStack {
                Text(icon)
                    .font(.largeTitle)
                Text(title)
                    .font(.system(size: 25, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
            }
        }
    }
}

// MARK: - صفحه نانوا (مدیریت موجودی)

struct BakerView: View {
    @State private var barbariText = ""
    @State private var taftoonText = ""
    @State private var sangakText = ""
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingOrders = false
    
    var body: some View {
        ZStack {
        
            Color(red: 0.75, green: 0.65, blue: 0.5).ignoresSafeArea()
           
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.backward.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                    }
      Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    
                }
            
                Text("مدیریت مواد")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                   // .padding(.top, 40)
                
                // نمایش موجودی نان‌ها
                ForEach(viewModel.bakerBreadStock) { bread in
                    HStack {
                        Text(bread.name)
                            .font(.system(size: 25, weight: .medium, design: .rounded))
                            .frame(width: 100)
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()

                            Button(action: { viewModel.addBread(bread.name) }) {
                                Image("done")
                                    .resizable()
                                    .font(.title)
                                    .foregroundColor(.green)
                                    .frame(width: 40, height: 40 )
                            
                    
                            
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(10)
                    .background(Color(red: 0.98, green: 0.98, blue: 0.9))
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                }
                ZStack {
                    Capsule()
                        .frame(width: 200, height: 60)
                        .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                    Text("سفارشات دریافتی")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.88, green: 0.90, blue: 0.88))
                }
                .padding()
                .foregroundColor(.white)
                .cornerRadius(12)
                
                
                Button(action: { showingOrders.toggle() }) {
                    ZStack {
                        Capsule()
                            .frame(width: 200, height: 60)
                            .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                        Text("سفارشات دریافتی")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.88, green: 0.90, blue: 0.88))
                    }
                }
                .padding(.top, 30)
                
                Spacer()
                Spacer()
                Spacer()

      
            }
        }
        .sheet(isPresented: $showingOrders) {
            BakerOrdersView(viewModel: viewModel)
        }
    }
}


// MARK: - صفحه مشتری (انتخاب نانوایی و ثبت سفارش)

struct CustomerView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedBakery: Bakery?
    @State private var customerName = ""
    @State private var orderItems: [Bread] = [
        Bread(name: "بربری", count: 0),
        Bread(name: "تافتون", count: 0),
        Bread(name: "سنگک", count: 0)
    ]
    @State private var showConfirmation = false
    
    var body: some View {
        ZStack {
            Color(red: 0.75, green: 0.65, blue: 0.5).ignoresSafeArea()
            VStack(spacing: 15) {
                Text("سفارش نان")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                    .padding(.top, 30)
                
                // انتخاب نانوایی
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.bakeries) { bakery in
                            Button(action: { selectedBakery = bakery }) {
                                VStack {
                                    Text(bakery.name)
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    Text(bakery.address)
                                        .font(.system(size: 12))
                                }
                                .padding()
                                .background(selectedBakery?.id == bakery.id ? Color.brown : Color(red: 0.98, green: 0.98, blue: 0.9))
                                .foregroundColor(selectedBakery?.id == bakery.id ? .white : .black)
                                .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                TextField("نام خود را وارد کنید", text: $customerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .font(.system(size: 18, design: .rounded))
                
                // سفارش نان‌ها
                ForEach($orderItems) { $item in
                    HStack {
                        Text(item.name)
                            .frame(width: 80)
                        Stepper("\(item.count) عدد", value: $item.count, in: 0...20)
                            .frame(width: 150)
                    }
                    .padding(.horizontal)
                    .font(.system(size: 18, design: .rounded))
                }
                
                Button(action: {
                    if !customerName.isEmpty, let bakery = selectedBakery {
                        let nonZeroItems = orderItems.filter { $0.count > 0 }
                        if !nonZeroItems.isEmpty {
                            viewModel.placeOrder(bakeryName: bakery.name, customerName: customerName, items: nonZeroItems)
                            showConfirmation = true
                            // ریست فرم
                            customerName = ""
                            for i in 0..<orderItems.count { orderItems[i].count = 0 }
                            selectedBakery = nil
                        }
                    }
                }) {
                    ZStack {
                        Capsule()
                            .frame(width: 200, height: 60)
                            .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                        Text("ثبت سفارش")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.88, green: 0.90, blue: 0.88))
                    }
                }
                .padding(.top)
                
                Spacer()
            }
        }
        .alert("سفارش ثبت شد", isPresented: $showConfirmation) {
            Button("باشه", role: .cancel) { }
        }
    }
}

// MARK: - صفحه پیک (مشاهده و تحویل سفارشات)

struct DeliveryView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var assignedOrder: Order?
    
    var pendingOrders: [Order] {
        viewModel.bakerOrders.filter { $0.status == .pending }
    }
    
    var deliveringOrders: [Order] {
        viewModel.bakerOrders.filter { $0.status == .onDelivery }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.75, green: 0.65, blue: 0.5).ignoresSafeArea()
            VStack {
                Text("پیک")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                    .padding(.top, 30)
                
                // سفارشات در حال ارسال
                if !deliveringOrders.isEmpty {
                    Text("سفارشات در حال ارسال")
                        .font(.title2)
                        .bold()
                    ForEach(deliveringOrders) { order in
                        OrderCard(order: order) {
                            viewModel.completeDelivery(order: order)
                        }
                        .environment(\.layoutDirection, .rightToLeft)
                    }
                }
                
                // سفارشات آماده
                if !pendingOrders.isEmpty {
                    Text("سفارشات آماده برای پیک")
                        .font(.title2)
                        .bold()
                        .padding(.top)
                    ForEach(pendingOrders) { order in
                        OrderCard(order: order) {
                            _ = viewModel.assignOrderToDelivery(order: order)
                        }
                        .environment(\.layoutDirection, .rightToLeft)
                    }
                }
                
                if pendingOrders.isEmpty && deliveringOrders.isEmpty {
                    Text("هیچ سفارشی موجود نیست")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
            }
        }
    }
}

struct OrderCard: View {
    let order: Order
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .trailing) {
            Text("نانوا: \(order.bakeryName)")
            Text("مشتری: \(order.customerName)")
            ForEach(order.items) { bread in
                Text("\(bread.name): \(bread.count) عدد")
            }
            Text("وضعیت: \(order.status.rawValue)")
                .foregroundColor(order.status == .pending ? .orange : .green)
            
            Button(action: action) {
                Text(order.status == .pending ? "گرفتن سفارش" : "تحویل شد")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
        }
        .font(.system(size: 16, design: .rounded))
        .padding()
        .background(Color(red: 0.98, green: 0.98, blue: 0.9))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

// MARK: - SignUpView (همان طراحی شما)

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @StateObject private var viewModel = AppViewModel()
    @State private var isLoggedIn = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.75, green: 0.65, blue: 0.5).ignoresSafeArea()
            Capsule()
                .frame(width: 400, height: 600)
                .padding(25)
                .foregroundColor(.brown)
                .shadow(color: .white, radius: 10)
            VStack {
                Spacer(minLength: 200)
                Label("ثبت نام", systemImage: "")
                    .bold()
                    .font(.system(size: 50, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                
                ZStack {
                    Capsule()
                        .frame(width: 350, height: 90)
                        .padding(25)
                        .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.9))
                        .shadow(color: .brown, radius: 10)
                    TextField("ایمیل", text: $email)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .padding(.leading, 70)
                }
                ZStack {
                    Capsule()
                        .frame(width: 350, height: 90)
                        .padding(25)
                        .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.9))
                        .shadow(color: .brown, radius: 10)
                    SecureField("رمز عبور", text: $password)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .padding(.leading, 70)
                }
                
                Button(action: { isLoggedIn = true }) {
                    ZStack {
                        Capsule()
                            .frame(width: 90, height: 90)
                            .padding(25)
                            .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                            .shadow(color: .brown, radius: 10)
                        Text("ثبت نام")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0.88, green: 0.90, blue: 0.88))
                    }
                    
                }
             
                Spacer(minLength: 210)
            }
            Spacer(minLength: 200)
        }
        
        .fullScreenCover(isPresented: $isLoggedIn) {
            NavigationView {
                RoleSelectionView(viewModel: viewModel)
            }
       
        }
      
    }
}
    
    
// MARK:orderviw
    
    
struct MainDashboardView: View {
//@ObservedObject var viewModel: AppViewModel
    @State private var path = [Route]()
    @ObservedObject var viewModel: AppViewModel
    @State private var showingOrders = false
    
    enum Route {
        case neworder
        case orders
        case inventory
        case salesReport
        case modirat
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color(red: 0.75, green: 0.65, blue: 0.5).ignoresSafeArea()
                
                VStack(spacing: 25) {
                    Spacer()
                    Spacer()
                    
                    Image("baker")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    
                    HStack {
                        Spacer(minLength: 1)
                        ZStack {
                            Label(" نانوایی برکت ", systemImage: "baker")
                                .bold()
                                .font(.system(size: 50, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    Button(action: {
                        path.append(.neworder)
                    }) {
                        HStack {
                            Spacer()
        
                            Text("سفارش جدید دارید !")
                            Spacer()
                        }
                        .font(.system(size: 25, weight: .medium, design: .rounded))
                        .padding()
                        .background(Color .init(red: 0.6, green: 0.04, blue: 0.08) )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .white, radius: 2)
                    }
                    .padding(.horizontal)
                    VStack(spacing: 15) {
                        // دکمه سفارشات
                        Button(action: {
                            path.append(.orders)
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "list.bullet.clipboard.fill")
                                Text("سفارشات")
                                Spacer()
                            }
                            .font(.system(size: 25, weight: .medium, design: .rounded))
                            .padding()
                            .background(Color .brown)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .white, radius: 2)
                        }
                        
                        // دکمه مدیریت مواد
                        Button(action: {
                            path.append(.modirat)
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "fork.knife.circle.fill")
                                Text("مدیریت مواد")
                                Spacer()
                            }
                            .font(.system(size: 25, weight: .medium, design: .rounded))
                            .padding()
                            .background(Color .brown)                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .white, radius: 2)
                        }
                        
                        // دکمه گزارش فروش
                        Button(action: {
                            path.append(.salesReport)
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "dollarsign.circle.fill")
                                Text("گزارش فروش")
                                Spacer()
                            }
                            .font(.system(size: 25, weight: .medium, design: .rounded))
                            .padding()
                            .background(Color .brown)                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .white, radius: 2)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            .environment(\.layoutDirection, .rightToLeft)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .neworder :
                    NewOrdersView(viewModel: viewModel)
                case .orders:
                    BakerOrdersView(viewModel: viewModel)
                case .inventory:
                    BakerView(viewModel: viewModel)
               case .salesReport:
                    BakerView(viewModel: viewModel)
                case .modirat:
                       InventoryManagementView()
                }
            }
        }
    }
}
struct BakerOrdersView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    // MARK: - سفارشات فیک (۵ عدد) - همه برای نانوایی برکت
    private var fakeOrders: [Order] {
        [
            Order(
                bakeryName: "نانوایی برکت",
                customerName: "سارا محمدی",
                items: [
                    Bread(name: "بربری", count: 5),
                    Bread(name: "سنگک", count: 2)
                ],
                status: .pending
            ),
            Order(
                bakeryName: "نانوایی برکت",
                customerName: "فاطمه کریمی",
                items: [
                    Bread(name: "بربری", count: 2),
                    Bread(name: "تافتون", count: 2),
                    Bread(name: "سنگک", count: 2)
                ],
                status: .pending
            ),
            Order(
                bakeryName: "نانوایی برکت",
                customerName: "زهرا خالقی",
                items: [
                    Bread(name: "سنگک", count: 3)
                ],
                status: .onDelivery
            ),
            Order(
                bakeryName: "نانوایی برکت",
                customerName: "رضا احمدی",
                items: [
                    Bread(name: "سنگک", count: 6)
                ],
                status: .onDelivery
            ),
            Order(
                bakeryName: "نانوایی برکت",
                customerName: "محمد رضایی",
                items: [
                    Bread(name: "تافتون", count: 4),
                    Bread(name: "بربری", count: 1)
                ],
                status: .delivered
            )
        ]
    }
    
    // MARK: - ترتیب بر اساس مرحله آماده‌سازی
    private var sortedOrders: [Order] {
        let statusOrder: [OrderStatus] = [.pending, .onDelivery, .delivered]
        return fakeOrders.sorted { order1, order2 in
            let index1 = statusOrder.firstIndex(of: order1.status) ?? 0
            let index2 = statusOrder.firstIndex(of: order2.status) ?? 0
            return index1 < index2
        }
    }
    
    var body: some View {
        ZStack {
            backgroundView
            mainContent
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    // MARK: - پس‌زمینه
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.75, green: 0.65, blue: 0.5),
                Color(red: 0.85, green: 0.75, blue: 0.6)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - محتوای اصلی
    private var mainContent: some View {
        VStack(spacing: 0) {
        
            ordersList
            closeButton
        }
    }
    
   
    // MARK: - تعداد سفارشات
    private var orderCountView: some View {
        HStack {
            // نمایش تعداد سفارشات بر اساس وضعیت
            HStack(spacing: 16) {
                statusCountBadge(status: .pending, count: sortedOrders.filter { $0.status == .pending }.count)
                statusCountBadge(status: .onDelivery, count: sortedOrders.filter { $0.status == .onDelivery }.count)
                statusCountBadge(status: .delivered, count: sortedOrders.filter { $0.status == .delivered }.count)
            }
            
            Spacer()
            
            Text("\(sortedOrders.count) سفارش")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2).opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.5))
                .cornerRadius(20)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - نشان تعداد بر اساس وضعیت
    private func statusCountBadge(status: OrderStatus, count: Int) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor(for: status))
                .frame(width: 6, height: 6)
            
            Text("\(count)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(statusColor(for: status))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor(for: status).opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - لیست سفارشات
    private var ordersList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(sortedOrders.indices, id: \.self) { index in
                    orderCard(for: sortedOrders[index], index: index)
                }
            }
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - کارت سفارش
    private func orderCard(for order: Order, index: Int) -> some View {
        VStack(alignment: .trailing, spacing: 12) {
            // وضعیت و شماره
            statusAndNumberView(order: order, index: index)
            
            // خط جداکننده
            Divider()
                .background(Color(red: 0.8, green: 0.75, blue: 0.7).opacity(0.4))
            
            // اطلاعات مشتری
            customerInfoView(order: order)
            
            // آیتم‌های سفارش
            orderItemsView(order: order)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    statusColor(for: order.status).opacity(0.3),
                    lineWidth: 1.5
                )
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - وضعیت و شماره
    private func statusAndNumberView(order: Order, index: Int) -> some View {
        HStack {
            statusBadge(order: order)
            Spacer()
            
            // مرحله آماده‌سازی (عدد)
            Text("مرحله \(index + 1)")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.gray.opacity(0.7))
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
    }
    
    // MARK: - نشان وضعیت
    private func statusBadge(order: Order) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor(for: order.status))
                .frame(width: 8, height: 8)
            
            Text(order.status.rawValue)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(statusColor(for: order.status))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(statusColor(for: order.status).opacity(0.12))
        .cornerRadius(12)
    }
    
    // MARK: - رنگ وضعیت
    private func statusColor(for status: OrderStatus) -> Color {
        switch status {
        case .pending:
            return .orange
        case .onDelivery:
            return .blue
        case .delivered:
            return .green
        }
    }
    
    // MARK: - اطلاعات مشتری
    private func customerInfoView(order: Order) -> some View {
        HStack(alignment: .center, spacing: 8) {
            // آواتار
            ZStack {
                Circle()
                    .fill(Color(red: 0.6, green: 0.25, blue: 0.15).opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Text(String(order.customerName.prefix(1)))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.6, green: 0.25, blue: 0.15))
            }
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(order.customerName)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                
                Text(order.bakeryName)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
    
    // MARK: - آیتم‌های سفارش
    private func orderItemsView(order: Order) -> some View {
        VStack(alignment: .trailing, spacing: 6) {
            Text("موارد سفارش:")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
            
            HStack(spacing: 8) {
                ForEach(order.items) { bread in
                    breadTag(bread: bread)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    // MARK: - تگ نان
    private func breadTag(bread: Bread) -> some View {
        HStack(spacing: 4) {
            Text(bread.name)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
            
            Text("×\(bread.count)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.6, green: 0.25, blue: 0.15))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color(red: 0.98, green: 0.96, blue: 0.92))
        .cornerRadius(10)
    }
    
    // MARK: - دکمه بستن
    private var closeButton: some View {
        Button(action: { dismiss() }) {
            HStack {
                Image(systemName: "chevron.down.circle.fill")
                    .font(.headline)
                Text("بستن")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(width: 160, height: 50)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.15, blue: 0.2),
                        Color(red: 0.35, green: 0.25, blue: 0.3)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        }
        .padding(.vertical, 20)
    }
}

    // کارت نمایش اعداد و آمار
    struct DashboardCard: View {
        let title: String
        let value: String
        let color: Color
        
        var body: some View {
            HStack {
                VStack(alignment: .trailing, spacing: 8) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("2")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(color)
                }
                Button(/*@START_MENU_TOKEN@*/"Button"/*@END_MENU_TOKEN@*/) {
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                }
                .padding(.trailing, 20)
                
                Spacer()
                
                Image(systemName: "bell.badge.fill")
                    .font(.largeTitle)
                    .foregroundColor(color.opacity(0.7))
                    .padding(.trailing, 10)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
        }
    }
    
    // دکمه‌های منو
    struct MenuButton: View {
        let title: String
        let icon: String
        let color: Color
        
        var body: some View {
            Button(action: {
                // action for each menu
                print("\(title) tapped")
            }) {
                HStack {
                    Spacer()
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 16)
                .padding(.horizontal)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [color.opacity(0.8), color]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
                .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
            }
        }
    }
    
    // پیش‌نمایش
    struct MainDashboardView_Previews: PreviewProvider {
        static var previews: some View {
            MainDashboardView(viewModel: AppViewModel())        }
    }

// MARK: - NewOrdersView (صفحه سفارشات جدید)

struct NewOrdersView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    // MARK: - سفارشات فیک جدید (۳ عدد) با آدرس
    @State private var newOrders: [Order] = [
        Order(
            bakeryName: "نانوایی برکت",
            customerName: "سارا محمدی",
            items: [
                Bread(name: "بربری", count: 5),
                Bread(name: "سنگک", count: 2)
            ],
            status: .pending
        ),
        Order(
            bakeryName: "نانوایی برکت",
            customerName: "حسین رضایی",
            items: [
                Bread(name: "تافتون", count: 3)
            ],
            status: .pending
        ),
        Order(
            bakeryName: "نانوایی برکت",
            customerName: "مریم حسینی",
            items: [
                Bread(name: "بربری", count: 2),
                Bread(name: "تافتون", count: 2)
            ],
            status: .pending
        )
    ]
    
    // آدرس‌های فیک برای مشتری‌ها
    private let customerAddresses: [String: String] = [
        "سارا محمدی": "خیابان صدرا، نبش چهارراه، پلاک ۱۲",
        "حسین رضایی": "خیابان جمهوری، پلاک ۳۲",
        "مریم حسینی": "خیابان ولیعصر، پلاک ۸"
    ]
    
    var body: some View {
        ZStack {
            backgroundView
            mainContent
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    // MARK: - پس‌زمینه
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.75, green: 0.65, blue: 0.5),
                Color(red: 0.85, green: 0.75, blue: 0.6)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - محتوای اصلی
    private var mainContent: some View {
        VStack(spacing: 0) {
            // هدر ساده (بدون هدر بزرگ)
            simpleHeader
            orderCountView
            ordersList
            closeButton
        }
    }
    
    // MARK: - هدر ساده
    private var simpleHeader: some View {
        HStack {
            Spacer()
            
            VStack(spacing: 2) {
                Image(systemName: "bell.badge.fill")
                    .font(.title2)
                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                    .symbolRenderingMode(.multicolor)
                
                Text("سفارشات جدید")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
            }
            
            Spacer()
        }
        .padding(.top, 12)
        .padding(.bottom, 4)
    }
    
    // MARK: - تعداد سفارشات
    private var orderCountView: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                
                Text("\(newOrders.count) سفارش جدید")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.12))
            .cornerRadius(20)
            
            Spacer()
            
            if newOrders.isEmpty {
                Text("همه سفارشات پذیرفته شد ✅")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
    
    // MARK: - لیست سفارشات
    private var ordersList: some View {
        ScrollView {
            if newOrders.isEmpty {
                // پیام خالی بودن لیست
                VStack(spacing: 20) {
                    Spacer(minLength: 60)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("همه سفارشات پذیرفته شدند! 🎉")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                    
                    Text("هیچ سفارش جدیدی وجود ندارد")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(newOrders.indices, id: \.self) { index in
                        newOrderCard(for: newOrders[index], index: index)
                    }
                }
                .padding(.vertical, 12)
            }
        }
    }
    
    // MARK: - کارت سفارش جدید
    private func newOrderCard(for order: Order, index: Int) -> some View {
        VStack(alignment: .trailing, spacing: 12) {
            // هدر کارت با شماره و نشان جدید
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    Text("جدید")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.7)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("همین الان")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            
            // خط جداکننده
            Divider()
                .background(Color(red: 0.8, green: 0.75, blue: 0.7).opacity(0.4))
            
            // اطلاعات مشتری
            customerInfoView(order: order)
            
            // آدرس
            addressView(for: order.customerName)
            
            // آیتم‌های سفارش
            orderItemsView(order: order)
            
            // دکمه پذیرش سفارش
            acceptButton(for: order)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.orange.opacity(0.4), Color.orange.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - اطلاعات مشتری
    private func customerInfoView(order: Order) -> some View {
        HStack(alignment: .center, spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.6, green: 0.25, blue: 0.15),
                                Color(red: 0.8, green: 0.4, blue: 0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Text(String(order.customerName.prefix(1)))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .shadow(color: Color(red: 0.6, green: 0.25, blue: 0.15).opacity(0.3), radius: 5)
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(order.customerName)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                
                Text(order.bakeryName)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
    
    // MARK: - آدرس
    private func addressView(for customerName: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.6, green: 0.25, blue: 0.15))
            
            Text(customerAddresses[customerName] ?? "آدرس نامشخص")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.trailing)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
        .background(Color(red: 0.98, green: 0.96, blue: 0.92))
        .cornerRadius(8)
    }
    
    // MARK: - آیتم‌های سفارش
    private func orderItemsView(order: Order) -> some View {
        VStack(alignment: .trailing, spacing: 6) {
            Text("موارد سفارش:")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
            
            HStack(spacing: 8) {
                ForEach(order.items) { bread in
                    breadTag(bread: bread)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    // MARK: - تگ نان
    private func breadTag(bread: Bread) -> some View {
        HStack(spacing: 4) {
            Text(bread.name)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
            
            Text("×\(bread.count)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.6, green: 0.25, blue: 0.15))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color(red: 0.98, green: 0.96, blue: 0.92))
        .cornerRadius(10)
    }
    
    // MARK: - دکمه پذیرش سفارش (با قابلیت حذف)
    private func acceptButton(for order: Order) -> some View {
        Button(action: {
            // حذف سفارش از لیست
            withAnimation(.easeInOut(duration: 0.3)) {
                if let index = newOrders.firstIndex(where: { $0.id == order.id }) {
                    newOrders.remove(at: index)
                }
            }
            
            // ویبره خفیف برای بازخورد
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.headline)
                Text("پذیرش سفارش")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.green,
                        Color.green.opacity(0.8)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color.green.opacity(0.3), radius: 5, y: 3)
        }
    }
    
    // MARK: - دکمه بستن
    private var closeButton: some View {
        Button(action: { dismiss() }) {
            HStack {
                Image(systemName: "chevron.down.circle.fill")
                    .font(.headline)
                Text("بستن")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(width: 160, height: 50)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.15, blue: 0.2),
                        Color(red: 0.35, green: 0.25, blue: 0.3)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        }
        .padding(.vertical, 20)
    }
}


//
//  InventoryManagementView.swift
//  Bakery
//
//  Created by Narges nurani on 2026.03.21.
//

import SwiftUI
import SwiftData

// MARK: - مدل داده SwiftData

@Model
class Ingredient {
    var name: String
    var quantity: Double
    var unit: String
    var minimumQuantity: Double
    var createdAt: Date
    
    init(name: String, quantity: Double, unit: String, minimumQuantity: Double = 5) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.minimumQuantity = minimumQuantity
        self.createdAt = Date()
    }
}

// MARK: - ViewModel

@MainActor
class InventoryViewModel: ObservableObject {
    @Published var ingredients: [Ingredient] = []
    @Published var searchText = ""
    @Published var showingAddSheet = false
    @Published var selectedIngredient: Ingredient?
    
    private var modelContext: ModelContext?
    
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchIngredients()
    }
    
    func fetchIngredients() {
        guard let modelContext = modelContext else { return }
        
        let descriptor = FetchDescriptor<Ingredient>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            ingredients = try modelContext.fetch(descriptor)
        } catch {
            print("خطا در دریافت مواد: \(error)")
        }
    }
    
    func addIngredient(name: String, quantity: Double, unit: String, minimumQuantity: Double) {
        guard let modelContext = modelContext else { return }
        
        let newIngredient = Ingredient(
            name: name,
            quantity: quantity,
            unit: unit,
            minimumQuantity: minimumQuantity
        )
        
        modelContext.insert(newIngredient)
        saveContext()
        fetchIngredients()
    }
    
    func updateIngredient(_ ingredient: Ingredient, quantity: Double) {
        ingredient.quantity = quantity
        saveContext()
        fetchIngredients()
    }
    
    func deleteIngredient(_ ingredient: Ingredient) {
        guard let modelContext = modelContext else { return }
        modelContext.delete(ingredient)
        saveContext()
        fetchIngredients()
    }
    
    func deleteAllIngredients() {
        guard let modelContext = modelContext else { return }
        for ingredient in ingredients {
            modelContext.delete(ingredient)
        }
        saveContext()
        fetchIngredients()
    }
    
    private func saveContext() {
        guard let modelContext = modelContext else { return }
        do {
            try modelContext.save()
        } catch {
            print("خطا در ذخیره‌سازی: \(error)")
        }
    }
    
    // مواد با موجودی کم
    var lowStockIngredients: [Ingredient] {
        ingredients.filter { $0.quantity <= $0.minimumQuantity }
    }
}

// MARK: - صفحه اصلی مدیریت مواد

struct InventoryManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = InventoryViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            backgroundView
            mainContent
        }
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear {
            viewModel.setup(modelContext: modelContext)
        }
        .sheet(isPresented: $viewModel.showingAddSheet) {
            AddIngredientSheet(viewModel: viewModel)
        }
    }
    
    // MARK: - پس‌زمینه
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.75, green: 0.65, blue: 0.5),
                Color(red: 0.85, green: 0.75, blue: 0.6)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - محتوای اصلی
    private var mainContent: some View {
        VStack(spacing: 0) {
            headerView
            searchBar
            statsView
            ingredientsList
            addButton
        }
    }
    
    // MARK: - هدر
    private var headerView: some View {
        ZStack {
      
            HStack {
                             if !viewModel.ingredients.isEmpty {
                    Button(action: {
                        viewModel.deleteAllIngredients()
                    }) {
                        Image(systemName: "trash.circle.fill")
                            .font(.title)
                            .foregroundColor(.red.opacity(0.8))
                    }
                    .padding(.trailing, 16)
                } else {
                    Color.clear
                        .frame(width: 40)
                }
            }
            .padding(.top, 20)
        }
    }
    
    // MARK: - جستجو
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 8)
            
            TextField("جستجوی مواد...", text: $viewModel.searchText)
                .font(.system(size: 16, design: .rounded))
                .padding(.vertical, 10)
                .autocapitalization(.none)
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
    
    // MARK: - آمار
    private var statsView: some View {
        HStack(spacing: 12) {
            // تعداد کل مواد
            StatBox(
                icon: "cube.box.fill",
                title: "کل مواد",
                value: "\(viewModel.ingredients.count)",
                color: .blue
            )
            
            // مواد با موجودی کم
            StatBox(
                icon: "exclamationmark.triangle.fill",
                title: "موجودی کم",
                value: "\(viewModel.lowStockIngredients.count)",
                color: viewModel.lowStockIngredients.isEmpty ? .green : .orange
            )
            
            // تنوع مواد
            let units = Set(viewModel.ingredients.map { $0.unit })
            StatBox(
                icon: "list.bullet.rectangle.portrait.fill",
                title: "واحدها",
                value: "\(units.count)",
                color: .purple
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
    
    // MARK: - لیست مواد
    private var ingredientsList: some View {
        ScrollView {
            if viewModel.ingredients.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 12) {
                    let filtered = viewModel.searchText.isEmpty ?
                        viewModel.ingredients :
                        viewModel.ingredients.filter { $0.name.contains(viewModel.searchText) }
                    
                    if filtered.isEmpty {
                        emptySearchView
                    } else {
                        ForEach(filtered) { ingredient in
                            IngredientCard(
                                ingredient: ingredient,
                                onUpdate: { newQuantity in
                                    viewModel.updateIngredient(ingredient, quantity: newQuantity)
                                },
                                onDelete: {
                                    viewModel.deleteIngredient(ingredient)
                                }
                            )
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - حالت خالی
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 60)
            
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 60))
                .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2).opacity(0.3))
            
            Text("هیچ ماده‌ای ثبت نشده")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
            
            Text("برای شروع، دکمه + را بزنید")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - حالت جستجوی خالی
    private var emptySearchView: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 40)
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.4))
            
            Text("نتیجه‌ای پیدا نشد")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.gray)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - دکمه افزودن
    private var addButton: some View {
        Button(action: {
            viewModel.showingAddSheet = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.headline)
                Text("افزودن ماده جدید")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.15, blue: 0.2),
                        Color(red: 0.35, green: 0.25, blue: 0.3)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

// MARK: - StatBox (کمپوننت آمار)

struct StatBox: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                
                Text(title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4)
    }
}

// MARK: - IngredientCard (کمپوننت کارت ماده)

struct IngredientCard: View {
    let ingredient: Ingredient
    let onUpdate: (Double) -> Void
    let onDelete: () -> Void
    
    @State private var quantity: Double
    @State private var showingDeleteAlert = false
    
    init(ingredient: Ingredient, onUpdate: @escaping (Double) -> Void, onDelete: @escaping () -> Void) {
        self.ingredient = ingredient
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        self._quantity = State(initialValue: ingredient.quantity)
    }
    
    var isLowStock: Bool {
        ingredient.quantity <= ingredient.minimumQuantity
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            HStack {
                // نشان موجودی کم
                if isLowStock {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        Text("موجودی کم")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(12)
                }
                
                Spacer()
                
                // دکمه حذف
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title3)
                        .foregroundColor(.red.opacity(0.6))
                }
                .alert("حذف ماده", isPresented: $showingDeleteAlert) {
                    Button("لغو", role: .cancel) { }
                    Button("حذف", role: .destructive) {
                        onDelete()
                    }
                } message: {
                    Text("آیا از حذف '\(ingredient.name)' مطمئن هستید؟")
                }
            }
            
            // نام ماده
            Text(ingredient.name)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            // واحد
            Text("واحد: \(ingredient.unit)")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            // مقدار
            HStack {
                Spacer()
                
                // دکمه کاهش
                Button(action: {
                    if quantity > 0 {
                        quantity -= 1
                        onUpdate(quantity)
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red.opacity(0.6))
                }
                
                Text("\(Int(quantity))")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(isLowStock ? .orange : Color(red: 0.2, green: 0.15, blue: 0.2))
                    .frame(width: 60)
                
                // دکمه افزایش
                Button(action: {
                    quantity += 1
                    onUpdate(quantity)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green.opacity(0.6))
                }
                
                // دکمه افزایش ۵ واحدی
                Button(action: {
                    quantity += 5
                    onUpdate(quantity)
                }) {
                    Text("+۵")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(8)
                }
            }
            
            // حداقل موجودی
            Text("حداقل موجودی: \(Int(ingredient.minimumQuantity)) \(ingredient.unit)")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isLowStock ? Color.orange.opacity(0.3) : Color.clear,
                    lineWidth: 1.5
                )
        )
    }
}

// MARK: - AddIngredientSheet (صفحه افزودن ماده)

struct AddIngredientSheet: View {
    @ObservedObject var viewModel: InventoryViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var quantity = ""
    @State private var unit = ""
    @State private var minimumQuantity = ""
    
    let units = ["کیلوگرم", "گرم", "لیتر", "میلی‌لیتر", "عدد", "بسته", "کیسه"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.98, green: 0.96, blue: 0.92)
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("اطلاعات ماده")) {
                        TextField("نام ماده", text: $name)
                            .font(.system(size: 16, design: .rounded))
                        
                        Picker("واحد", selection: $unit) {
                            ForEach(units, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                    }
                    
                    Section(header: Text("مقدار")) {
                        TextField("مقدار", text: $quantity)
                            .font(.system(size: 16, design: .rounded))
                            .keyboardType(.decimalPad)
                        
                        TextField("حداقل موجودی", text: $minimumQuantity)
                            .font(.system(size: 16, design: .rounded))
                            .keyboardType(.decimalPad)
                    }
                    
                    Section {
                        Button(action: addIngredient) {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                Text("افزودن ماده")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                isFormValid ? Color(red: 0.2, green: 0.15, blue: 0.2) : Color.gray
                            )
                            .cornerRadius(12)
                        }
                        .disabled(!isFormValid)
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("افزودن ماده جدید")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("لغو") {
                        dismiss()
                    }
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
    }
    
    var isFormValid: Bool {
        !name.isEmpty &&
        !unit.isEmpty &&
        Double(quantity) != nil &&
        Double(minimumQuantity) != nil
    }
    
    func addIngredient() {
        guard let quantity = Double(quantity),
              let minQuantity = Double(minimumQuantity) else { return }
        
        viewModel.addIngredient(
            name: name,
            quantity: quantity,
            unit: unit,
            minimumQuantity: minQuantity
        )
        
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Ingredient.self, configurations: config)
    
    return InventoryManagementView()
        .modelContainer(container)
}
    // MARK: - Preview
    
    #Preview {
        WelcomeView()
    }
