//
//  Storesystem.swift
//  GigaNeko
//
//  Created by 平井旭晃 on 2024/11/25.
//

import Foundation

class StoreSystem: ObservableObject {
    @Published var pointSystem: PointSystem
    
    let feedarray = [0:24, 100:48, 200:72, 900:240] //餌[必要ポイント : 時間]
    let presentarray = [1000:100, 5000:500, 10000:1000] //プレゼント[必要ポイント : 好感度]
    
    // 初期化時にPointSystemを受け取る
    init(pointSystem: PointSystem) {
        self.pointSystem = pointSystem
    }
    
    //餌
    func feed(point: Int) {
        if let hours = feedarray[point] {
            //ポイントの消費
            pointSystem.consumePoints(consumptionPoints: point)
            if pointSystem.alertMessage == nil {
                //スタミナ追加
                
                print("\(hours)時間分の餌を購入しました")
            } else {
                print(pointSystem.alertMessage ?? "エラーが発生しました")
            }
        }
    }
    
    //おもちゃ
    func toys(point: Int){
        //ポイントの消費
        pointSystem.consumePoints(consumptionPoints: point)
        //ストレス値低下
        
    }
    
    //プレゼント
    func present(point: Int){
        if let present = presentarray[point] {
            //ポイントの消費
            pointSystem.consumePoints(consumptionPoints: point)
            if pointSystem.alertMessage == nil {
                //好感度追加
                
                print("\(present)分の好感度が上がりました")
            } else {
                print(pointSystem.alertMessage ?? "エラーが発生しました")
            }
        }
    }
}
