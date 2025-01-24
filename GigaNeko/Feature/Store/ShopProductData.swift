class ShopProductData {
    let feeds: [ShopProduct] = [
        ShopProduct(name: "普通の餌", price: 0, category: "feed", image: "FoodNormal",
                   description: "猫に与えられる餌アイテムです\n空腹ゲージを24時間回復します",
                   subText: "※ 新しく食べた餌の継続時間は今の継続時間には追加されず上書きされます"),
        ShopProduct(name: "猫缶", price: 100, category: "feed", image: "FoodNekocan",
                   description: "猫に与えられる餌アイテムです\n空腹ゲージを48時間回復します",
                   subText: "※ 新しく食べた餌の継続時間は今の継続時間には追加されず上書きされます"),
        ShopProduct(name: "刺身", price: 200, category: "feed", image: "FoodSashimi",
                   description: "猫に与えられる餌アイテムです\n空腹ゲージを72時間回復します",
                   subText: "※ 新しく食べた餌の継続時間は今の継続時間には追加されず上書きされます"),
        ShopProduct(name: "またたび", price: 900, category: "feed", image: "FoodMatatabi",
                   description: "猫に与えられる餌アイテムです\n空腹ゲージを240時間回復します",
                   subText: "※ 新しく食べた餌の継続時間は今の継続時間には追加されず上書きされます")
    ]
    
    let toys: [ShopProduct] = [
        ShopProduct(name: "猫じゃらし", price: 20, category: "toys", image: "ToyNeko",
                   description: "ストレス値を20減少させることができます。", subText: "")
    ]
    
    let presents: [ShopProduct] = [
        ShopProduct(name: "赤色の袋", price: 1000, category: "presents", image: "PresentRed",
                   description: "好感度が100上がります", subText: ""),
        ShopProduct(name: "青色の袋", price: 5000, category: "presents", image: "PresentBlue",
                   description: "好感度が500上がります", subText: ""),
        ShopProduct(name: "黄色の袋", price: 8000, category: "presents", image: "PresentYellow",
                   description: "好感度が1000上がります", subText: "")
    ]
    
    let points: [ShopProduct] = [
        ShopProduct(name: "120pt", price: 160, category: "points", image: "Point",
                   description: "120pt獲得できます", subText: ""),
        ShopProduct(name: "380pt", price: 480, category: "points", image: "Point",
                   description: "380pt獲得できます", subText: ""),
        ShopProduct(name: "800pt", price: 1000, category: "points", image: "Point",
                   description: "800pt獲得できます", subText: ""),
        ShopProduct(name: "1200pt", price: 1500, category: "points", image: "Point",
                   description: "1200pt獲得できます", subText: ""),
        ShopProduct(name: "2400pt", price: 3000, category: "points", image: "Point",
                   description: "2400pt獲得できます", subText: ""),
        ShopProduct(name: "3900pt", price: 5000, category: "points", image: "Point",
                   description: "3900pt獲得できます", subText: ""),
    ]
}
