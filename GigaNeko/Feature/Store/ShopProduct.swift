struct ShopProduct: Identifiable {
    let id: Int
    let name: String
    let price: Int
    let category: ShopProductCategory
    let image: String
    let description: String
    let subText: String
    let productId: String
    
    init(id: Int, name: String, price: Int, category: String, image: String, description: String, subText: String, productId: String) {
        self.id = id
        self.name = name
        self.price = price
        self.category = ShopProductCategory(rawValue: category) ?? .feed
        self.image = image
        self.description = description
        self.subText = subText
        self.productId = productId
    }
}

enum ShopProductCategory: String {
    case feed = "feed"
    case toys = "toys"
    case presents = "presents"
    case points = "points"
}
