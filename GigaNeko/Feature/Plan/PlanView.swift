//
//  PlanView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2025/01/16.
//

import SwiftUI

struct MobilePlan: Identifiable {
    let id = UUID()
    let brand: String
    let planName: String
    let dataAmount: String
    let monthlyFee: Int
    let isOver20GB: Bool
}

struct MobilePlansView: View {
    let plans: [MobilePlan] = [
        // 20GB以下のプラン
        MobilePlan(brand: "docomo", planName: "eximo", dataAmount: "無制限", monthlyFee: 5665, isOver20GB: false),
        MobilePlan(brand: "au", planName: "スマホミニプラン 5G", dataAmount: "~4GB", monthlyFee: 5665, isOver20GB: false),
        MobilePlan(brand: "Softbank", planName: "ミニフィットプラン+", dataAmount: "~3GB", monthlyFee: 5478, isOver20GB: false),
        MobilePlan(brand: "Rakuten Mobile", planName: "Rakuten最強プラン", dataAmount: "無制限", monthlyFee: 1078, isOver20GB: false),
        MobilePlan(brand: "irmo", planName: "3GBプラン", dataAmount: "3GB", monthlyFee: 2167, isOver20GB: false),
        MobilePlan(brand: "povo", planName: "povo2.0", dataAmount: "3GB", monthlyFee: 990, isOver20GB: false),
        MobilePlan(brand: "UQ mobile", planName: "ミニミニプラン", dataAmount: "4GB", monthlyFee: 2365, isOver20GB: false),
        MobilePlan(brand: "LINEMO", planName: "LINEMOベストプラン", dataAmount: "3~10GB", monthlyFee: 990, isOver20GB: false),
        MobilePlan(brand: "Ymobile", planName: "シンプル2 S", dataAmount: "4GB", monthlyFee: 2365, isOver20GB: false),
        
        // 20GB以上のプラン
        MobilePlan(brand: "docomo", planName: "eximo", dataAmount: "無制限", monthlyFee: 7315, isOver20GB: true),
        MobilePlan(brand: "au", planName: "使い放題MAX 5G", dataAmount: "無制限", monthlyFee: 7238, isOver20GB: true),
        MobilePlan(brand: "Softbank", planName: "メリハリ無制限＋", dataAmount: "無制限", monthlyFee: 7425, isOver20GB: true),
        MobilePlan(brand: "Rakuten Mobile", planName: "Rakuten最強プラン", dataAmount: "無制限", monthlyFee: 2178, isOver20GB: true),
        MobilePlan(brand: "ahamo", planName: "ahamo", dataAmount: "30GB", monthlyFee: 2970, isOver20GB: true),
        MobilePlan(brand: "povo", planName: "povo2.0", dataAmount: "実質20GB", monthlyFee: 2163, isOver20GB: true),
        MobilePlan(brand: "UQ mobile", planName: "コミコミプラン", dataAmount: "30GB", monthlyFee: 3278, isOver20GB: true),
        MobilePlan(brand: "LINEMO", planName: "LINEMOベストプランV", dataAmount: "20～30GB", monthlyFee: 2970, isOver20GB: true),
        MobilePlan(brand: "Ymobile", planName: "シンプル2 M", dataAmount: "20GB", monthlyFee: 4015, isOver20GB: true)
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("20GB以下のプラン")) {
                    ForEach(plans.filter { !$0.isOver20GB }) { plan in
                        PlanRow(plan: plan)
                    }
                }
                
                Section(header: Text("20GB以上のプラン")) {
                    ForEach(plans.filter { $0.isOver20GB }) { plan in
                        PlanRow(plan: plan)
                    }
                }
            }
            .navigationTitle("携帯料金プラン比較")
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

struct MobilePlansView_Previews: PreviewProvider {
    static var previews: some View {
        MobilePlansView()
    }
}
