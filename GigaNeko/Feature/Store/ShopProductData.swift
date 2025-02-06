class ShopProductData {
    let feeds: [ShopProduct] = [
        ShopProduct(id: 0, name: "普通の餌", price: 0, category: "feed", image: "FoodNormal",
                   description: "猫に与えられる餌アイテムです\n空腹ゲージを24時間回復します",
                    subText: "※ 新しく食べた餌の継続時間は今の継続時間には追加されず上書きされます", productId: ""),
        ShopProduct(id: 1, name: "猫缶", price: 100, category: "feed", image: "FoodNekocan",
                   description: "猫に与えられる餌アイテムです\n空腹ゲージを48時間回復します",
                   subText: "※ 新しく食べた餌の継続時間は今の継続時間には追加されず上書きされます", productId: ""),
        ShopProduct(id: 2, name: "刺身", price: 200, category: "feed", image: "FoodSashimi",
                   description: "猫に与えられる餌アイテムです\n空腹ゲージを72時間回復します",
                   subText: "※ 新しく食べた餌の継続時間は今の継続時間には追加されず上書きされます", productId: ""),
        ShopProduct(id: 3, name: "またたび", price: 900, category: "feed", image: "FoodMatatabi",
                   description: "猫に与えられる餌アイテムです\n空腹ゲージを240時間回復します",
                   subText: "※ 新しく食べた餌の継続時間は今の継続時間には追加されず上書きされます", productId: "")
    ]
    
    let toys: [ShopProduct] = [
        ShopProduct(id: 0, name: "猫じゃらし", price: 20, category: "toys", image: "ToyNeko",
                   description: "ストレス値を20減少させることができます。", subText: "", productId: "")
    ]
    
    let presents: [ShopProduct] = [
        ShopProduct(id: 0, name: "赤色の袋", price: 1000, category: "presents", image: "PresentRed",
                   description: "好感度が100上がります", subText: "", productId: ""),
        ShopProduct(id: 1, name: "青色の袋", price: 5000, category: "presents", image: "PresentBlue",
                   description: "好感度が500上がります", subText: "", productId: ""),
        ShopProduct(id: 2, name: "黄色の袋", price: 8000, category: "presents", image: "PresentYellow",
                   description: "好感度が1000上がります", subText: "", productId: "")
    ]
    
    let points: [ShopProduct] = [
        ShopProduct(id: 0, name: "120pt", price: 120, category: "points", image: "Point",
                   description: "120pt獲得できます", subText: "", productId: "GigaPoint120"),
        ShopProduct(id: 1, name: "630pt", price: 600, category: "points", image: "Point",
                   description: "630pt獲得できます（30ptボーナス）", subText: "", productId: "GigaPoint630"),
        ShopProduct(id: 2, name: "1,320pt", price: 1200, category: "points", image: "Point",
                   description: "1320pt獲得できます（120ptボーナス）", subText: "", productId: "GigaPoint1320"),
        ShopProduct(id: 3, name: "2,760pt", price: 2400, category: "points", image: "Point",
                   description: "2760pt獲得できます（360ptボーナス）", subText: "", productId: "GigaPoint2760"),
        ShopProduct(id: 4, name: "5,760pt", price: 4800, category: "points", image: "Point",
                   description: "5760pt獲得できます（960ptボーナス）", subText: "", productId: "GigaPoint5760"),
        ShopProduct(id: 5, name: "12,000pt", price: 9600, category: "points", image: "Point",
                   description: "12000pt獲得できます（2400ptボーナス）", subText: "", productId: "GigaPoint12000")
    ]
}
