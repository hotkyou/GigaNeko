struct ShopProduct: Identifiable {
    let id: String
    let name: String
    let price: Int
    let category: ShopProductCategory
    let image: String
    let description: String
    let subText: String
    
    init(name: String, price: Int, category: String, image: String, description: String, subText: String) {
        self.id = name
        self.name = name
        self.price = price
        self.category = ShopProductCategory(rawValue: category) ?? .feed
        self.image = image
        self.description = description
        self.subText = subText
    }
}

enum ShopProductCategory: String {
    case feed = "feed"
    case toys = "toys"
    case presents = "presents"
    case points = "points"
}
