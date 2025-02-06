import SwiftUI
import Foundation

struct MobilePlan: Identifiable {
    let id = UUID()
    let brand: String
    let planName: String
    let dataAmount: String
    let monthlyFee: Int
    let isOver20GB: Bool
    let important: String
    let parentCarrier: String
    let dataAmountGB: Int?

    init(brand: String, planName: String, dataAmount: String, monthlyFee: Int, isOver20GB: Bool, important: String, parentCarrier: String) {
        self.brand = brand
        self.planName = planName
        self.dataAmount = dataAmount
        self.monthlyFee = monthlyFee
        self.isOver20GB = isOver20GB
        self.important = important
        self.parentCarrier = parentCarrier
        self.dataAmountGB = dataAmount == "無制限" ? nil : Int(dataAmount.replacingOccurrences(of: "GB", with: ""))
    }
}

struct MobilePlansView: View {
    @State private var selectedTab = 0
    @State private var dataFilter: String = "全て"
    @State private var priceFilter: Int = 10000
    @State private var showImportantOnly: Bool = false
    @State private var parentCarrierFilter: String = "全て"
    @State private var userDataUsage: Int = 0
    @State private var additionalData: Int = 0
    @State private var showUnlimitedPlans: Bool = true
    @State private var sortOrder: SortOrder = .none
    
    enum SortOrder {
        case none, gbAscending, gbDescending, priceAscending, priceDescending
    }
    
    let plans: [MobilePlan] = [
        // 20GB以下のプラン
        MobilePlan(brand: "docomo", planName: "eximo", dataAmount: "無制限", monthlyFee: 5665, isOver20GB: false, important: "", parentCarrier: ""),
        MobilePlan(brand: "au", planName: "スマホミニプラン 5G", dataAmount: "4GB", monthlyFee: 5665, isOver20GB: false, important: "", parentCarrier: ""),
        MobilePlan(brand: "Softbank", planName: "ミニフィットプラン+", dataAmount: "3GB", monthlyFee: 5478, isOver20GB: false, important: "", parentCarrier: ""),
        MobilePlan(brand: "Rakuten Mobile", planName: "Rakuten最強プラン", dataAmount: "無制限", monthlyFee: 1078, isOver20GB: false, important: "", parentCarrier: ""),
        MobilePlan(brand: "irmo", planName: "3GBプラン", dataAmount: "3GB", monthlyFee: 2167, isOver20GB: false, important: "", parentCarrier: ""),
        MobilePlan(brand: "povo", planName: "povo2.0", dataAmount: "3GB", monthlyFee: 990, isOver20GB: false, important: "", parentCarrier: ""),
        MobilePlan(brand: "UQ mobile", planName: "ミニミニプラン", dataAmount: "4GB", monthlyFee: 2365, isOver20GB: false, important: "", parentCarrier: ""),
        MobilePlan(brand: "LINEMO", planName: "LINEMOベストプラン", dataAmount: "3GB", monthlyFee: 990, isOver20GB: false, important: "", parentCarrier: ""),
        MobilePlan(brand: "LINEMO", planName: "LINEMOベストプラン", dataAmount: "10GB", monthlyFee: 990, isOver20GB: false, important: "", parentCarrier: ""),
        MobilePlan(brand: "Ymobile", planName: "シンプル2 S", dataAmount: "4GB", monthlyFee: 2365, isOver20GB: false, important: "", parentCarrier: ""),
        
        // 20GB以上のプラン
        MobilePlan(brand: "docomo", planName: "eximo", dataAmount: "無制限", monthlyFee: 7315, isOver20GB: true, important: "", parentCarrier: ""),
        MobilePlan(brand: "au", planName: "使い放題MAX 5G", dataAmount: "無制限", monthlyFee: 7238, isOver20GB: true, important: "", parentCarrier: ""),
        MobilePlan(brand: "Softbank", planName: "メリハリ無制限＋", dataAmount: "無制限", monthlyFee: 7425, isOver20GB: true, important: "", parentCarrier: ""),
        MobilePlan(brand: "Rakuten Mobile", planName: "Rakuten最強プラン", dataAmount: "無制限", monthlyFee: 3278, isOver20GB: true, important: "", parentCarrier: ""),
        MobilePlan(brand: "ahamo", planName: "ahamo", dataAmount: "30GB", monthlyFee: 2970, isOver20GB: true, important: "", parentCarrier: ""),
        MobilePlan(brand: "povo", planName: "povo2.0", dataAmount: "20GB", monthlyFee: 2163, isOver20GB: true, important: "", parentCarrier: ""),
        MobilePlan(brand: "UQ mobile", planName: "コミコミプラン", dataAmount: "30GB", monthlyFee: 3278, isOver20GB: true, important: "", parentCarrier: ""),
        MobilePlan(brand: "LINEMO", planName: "LINEMOベストプランV", dataAmount: "30GB", monthlyFee: 2970, isOver20GB: true, important: "", parentCarrier: ""),
        MobilePlan(brand: "Ymobile", planName: "シンプル2 M", dataAmount: "20GB", monthlyFee: 4015, isOver20GB: true, important: "", parentCarrier: "")
    ]
    
    var filteredPlans: [MobilePlan] {
        let filtered = plans.filter { plan in
            let dataCondition: Bool
            switch dataFilter {
            case "全て": dataCondition = true
            case "20GB以下": dataCondition = !plan.isOver20GB
            case "20GB以上": dataCondition = plan.isOver20GB
            case "今月の使用量": dataCondition = (plan.dataAmountGB != nil && plan.dataAmountGB! <= (userDataUsage + additionalData)) || (showUnlimitedPlans && plan.dataAmountGB == nil)
            default: dataCondition = true
            }
            
            return dataCondition && (plan.monthlyFee <= priceFilter) && (!showImportantOnly || !plan.important.isEmpty) && (parentCarrierFilter == "全て" || plan.parentCarrier == parentCarrierFilter)
        }
        
        switch sortOrder {
        case .gbAscending:
            return filtered.sorted { ($0.dataAmountGB ?? Int.max) < ($1.dataAmountGB ?? Int.max) }
        case .gbDescending:
            return filtered.sorted { ($0.dataAmountGB ?? Int.max) > ($1.dataAmountGB ?? Int.max) }
        case .priceAscending:
            return filtered.sorted { $0.monthlyFee < $1.monthlyFee }
        case .priceDescending:
            return filtered.sorted { $0.monthlyFee > $1.monthlyFee }
        case .none:
            return filtered
        }
    }
    
    var recommendedPlan: MobilePlan? {
        let totalUsage = userDataUsage + additionalData
        let eligiblePlans = plans.filter { plan in
            if let planData = plan.dataAmountGB {
                return planData >= totalUsage
            } else {
                return true // 無制限プランは常に適格
            }
        }
        return eligiblePlans.min(by: { $0.monthlyFee < $1.monthlyFee })
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                DataFilterView(dataFilter: $dataFilter, userDataUsage: $userDataUsage, additionalData: $additionalData, showUnlimitedPlans: $showUnlimitedPlans)
                    .tabItem {
                        Image(systemName: "network")
                        Text("データ")
                    }.tag(0)
                
                PriceFilterView(priceFilter: $priceFilter)
                    .tabItem {
                        Image(systemName: "yensign.circle")
                        Text("料金")
                    }.tag(1)
                
                CarrierFilterView(parentCarrierFilter: $parentCarrierFilter, showImportantOnly: $showImportantOnly)
                    .tabItem {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                        Text("キャリア")
                    }.tag(2)
            }
            .frame(height: 150)
            
            if let recommended = recommendedPlan {
                RecommendedPlanView(plan: recommended, userDataUsage: userDataUsage + additionalData)
            }
            
            SortOrderPicker(sortOrder: $sortOrder)
                .padding(.vertical, 8)
            
            PlanList(filteredPlans: filteredPlans)
        }
        .navigationBarTitle("携帯料金プラン比較", displayMode: .inline)
        .navigationBarBackButtonHidden(false)
    }
}

struct DataFilterView: View {
    @Binding var dataFilter: String
    @Binding var userDataUsage: Int
    @Binding var additionalData: Int
    @Binding var showUnlimitedPlans: Bool
    
    let dataOptions = ["全て", "20GB以下", "20GB以上", "今月の使用量"]
    
    var body: some View {
        VStack {
            Picker("データ量", selection: $dataFilter) {
                ForEach(dataOptions, id: \.self) { Text($0) }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if dataFilter == "今月の使用量" {
                HStack {
                    Text("今月の使用量:")
                    Text("\(userDataUsage)GB + \(additionalData)GB")
                        .bold()
                    Stepper("", value: $additionalData, in: -userDataUsage...100)
                }
            }
            
            Toggle("無制限プランを表示", isOn: $showUnlimitedPlans)
        }
        .padding()
    }
}

struct PriceFilterView: View {
    @Binding var priceFilter: Int
    
    var body: some View {
        VStack {
            Slider(value: Binding(get: { Double(priceFilter) },
                                  set: { priceFilter = Int($0) }),
                   in: 0...10000, step: 1000)
            Text("最大料金: ¥\(priceFilter)")
        }
        .padding()
    }
}

struct CarrierFilterView: View {
    @Binding var parentCarrierFilter: String
    @Binding var showImportantOnly: Bool
    
    let parentCarriers = ["全て", "docomo", "au", "Softbank"]
    
    var body: some View {
        VStack {
            Picker("親回線", selection: $parentCarrierFilter) {
                ForEach(parentCarriers, id: \.self) { Text($0) }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Toggle("注意点のあるプランのみ", isOn: $showImportantOnly)
        }
        .padding()
    }
}

struct SortOrderPicker: View {
    @Binding var sortOrder: MobilePlansView.SortOrder
    
    var body: some View {
        Picker("並び替え", selection: $sortOrder) {
            Text("標準").tag(MobilePlansView.SortOrder.none)
            Text("GB少").tag(MobilePlansView.SortOrder.gbAscending)
            Text("GB多").tag(MobilePlansView.SortOrder.gbDescending)
            Text("料金低").tag(MobilePlansView.SortOrder.priceAscending)
            Text("料金高").tag(MobilePlansView.SortOrder.priceDescending)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
}

struct PlanList: View {
    let filteredPlans: [MobilePlan]
    
    var body: some View {
        List(filteredPlans) { plan in
            PlanRow(plan: plan)
        }
    }
}

struct PlanRow: View {
    let plan: MobilePlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(plan.brand)
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
                Text("¥\(plan.monthlyFee)")
                    .font(.headline)
                    .foregroundColor(.red)
            }
            
            HStack {
                Text(plan.planName)
                    .font(.subheadline)
                Spacer()
                Text(plan.dataAmount)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

struct RecommendedPlanView: View {
    let plan: MobilePlan
    let userDataUsage: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("おすすめプラン")
                .font(.headline)
                .foregroundColor(.green)
            HStack {
                VStack(alignment: .leading) {
                    Text(plan.brand)
                        .font(.subheadline)
                    Text(plan.planName)
                        .font(.caption)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("¥\(plan.monthlyFee)")
                        .font(.subheadline)
                    Text(plan.dataAmount)
                        .font(.caption)
                }
            }
            Text("使用量: \(userDataUsage)GB")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct MobilePlansView_Previews: PreviewProvider {
    static var previews: some View {
        MobilePlansView()
    }
}
