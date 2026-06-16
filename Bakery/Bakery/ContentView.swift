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
        case orders
        case inventory
        case salesReport
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
                    
                    DashboardCard(title: "عدد سفارش جدید", value: "۲", color: .init(red: 0.6, green: 0.04, blue: 0.08))
                    
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
                            path.append(.inventory)
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
                case .orders:
                    BakerOrdersView(viewModel: viewModel)
                case .inventory:
                    BakerView(viewModel: viewModel)
               case .salesReport:
                    BakerView(viewModel: viewModel)
                }
            }
        }
    }
}
struct BakerOrdersView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.75, green: 0.65, blue: 0.5).ignoresSafeArea()
            VStack {
                Text("سفارشات")
                    .font(.system(size: 35, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.2))
                    .padding()
                
                ScrollView {
                    ForEach(viewModel.bakerOrders) { order in
                        VStack(alignment: .trailing) {
                            Text("مشتری: \(order.customerName)")
                            Text("نانوا: \(order.bakeryName)")
                            ForEach(order.items) { bread in
                                Text("\(bread.name): \(bread.count) عدد")
                            }
                            Text("وضعیت: \(order.status.rawValue)")
                                .foregroundColor(order.status == .delivered ? .green : .orange)
                        }
                        .font(.system(size: 18, design: .rounded))
                        .padding()
                        .background(Color(red: 0.98, green: 0.98, blue: 0.9))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                }
                
                Button("بستن") { dismiss() }
                    .padding()
                    .background(Color(red: 0.2, green: 0.15, blue: 0.2))
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        }
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
                    Text(value)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(color)
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

    // MARK: - Preview
    
    #Preview {
        WelcomeView()
    }
