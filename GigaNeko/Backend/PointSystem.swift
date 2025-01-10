import Foundation

class PointSystem: ObservableObject {
    // MARK: - 公開プロパティ
    ///現在のポイント
    @Published var currentPoints: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.currentPoints, value: currentPoints) }
    }
    ///一時間あたりのポイント
    @Published var pointsPerGB: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.pointsPerGB, value: pointsPerGB) }
    }
    ///スタミナ
    @Published var stamina: Double {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.stamina, value: stamina) }
    }
    ///スタミナ持続時間
    @Published var staminaTime: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.staminaTime, value: staminaTime) }
    }
    ///一時間あたりのスタミナ
    @Published var perhourStamina: Double {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.perhourStamina, value: perhourStamina) }
    }
    ///ストレス
    @Published var stress: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.stress, value: stress) }
    }
    ///好感度レベル
    @Published var like: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.like, value: like) }
    }
    
    ///好感度経験値
    @Published var likeExperience: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.like, value: likeExperience) }
    }
    
    ///好感度レベルアップに必要な経験値
    @Published var likeUp: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.like, value: likeUp) }
    }
    
    ///キャットタワー効果ポイント
    @Published var addLike: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.like, value: addLike) }
    }
    ///招き猫効果のポイント
    @Published var addPoint: Double {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.like, value: addPoint) }
    }
    ///宝箱効果のポイント
    @Published var addPresents: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.like, value: addPresents) }
    }
    ///招き猫レベル
    @Published var manekineko: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.like, value: manekineko) }
    }
    ///招き猫をレベルUPに必要なポイント
    @Published var mlevelUp: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.like, value: mlevelUp) }
    }
    ///キャットタワーレベル
    @Published var catTower: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.like, value: catTower) }
    }
    ///キャットタワーレベルUPに必要なポイント
    @Published var clevelUp: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.like, value: clevelUp) }
    }
    ///宝箱レベル
    @Published var treasure: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.like, value: treasure) }
    }
    ///宝箱レベルUPに必要なポイント
    @Published var tlevelUp: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.like, value: tlevelUp) }
    }
    ///最終ログイン
    @Published var lastLogin: Date {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.like, value: lastLogin) }
    }
    @Published var alertMessage: String?

    // MARK: - 定数
    private static let maxPoints = 3000 // 一ヶ月にもらえる最大のポイント数
    private static let billingOptions = [120, 380, 800, 1200, 2400, 3900, 8000] // 課金ポイント量
    private static let feedOptions = [0: 24, 100: 48, 200: 72, 900: 240] // 必要ポイント: スタミナ時間
    private static let giftOptions = [1000: 100, 5000: 500, 10000: 1000] // 必要ポイント: 好感度
    private static let reduction = 20 //ストレス削減値

    // UserDefaultsキー
    private struct UserDefaultsKeys {
        static let currentPoints = "PointSystem.currentPoints"
        static let pointsPerGB = "PointSystem.pointsPerGB"
        static let stamina = "PointSystem.stamina"
        static let staminaTime = "PointSystem.staminaTime"
        static let perhourStamina = "PointSystem.perhourStamina"
        static let stress = "PointSystem.stress"
        static let like = "PointSystem.like"
        static let likeExperience = "PointSystem.likeExperience"
        static let likeUp = "PointSystem.likeUp"
        static let addLike = "PointSystem.addLike"
        static let addPoint = "PointSystem.addPoint"
        static let addPresents = "PointSystem.addPresents"
        static let manekineko = "PointSystem.manekineko"
        static let mlevelUp = "PointSystem.mlevelUp"
        static let catTower = "PointSystem.catTower"
        static let clevelUp = "PointSystem.mlevelUp"
        static let treasure = "PointSystem.treasure"
        static let tlevelUp = "PointSystem.mlevelUp"
        static let lastLogin = "PointSystem.lastLogin"
        
    }

    // MARK: - 初期化
    init() {
        // プロパティを直接初期化
        self.currentPoints = UserDefaults.standard.value(forKey: UserDefaultsKeys.currentPoints) as? Int ?? 0
        self.pointsPerGB = UserDefaults.standard.value(forKey: UserDefaultsKeys.pointsPerGB) as? Int ?? 0
        self.stamina = UserDefaults.standard.value(forKey: UserDefaultsKeys.stamina) as? Double ?? 51.0
        self.staminaTime = UserDefaults.standard.value(forKey: UserDefaultsKeys.staminaTime) as? Int ?? 24
        self.perhourStamina = UserDefaults.standard.value(forKey: UserDefaultsKeys.perhourStamina) as? Double ?? 4.1666666667
        self.stress = UserDefaults.standard.value(forKey: UserDefaultsKeys.stress) as? Int ?? 0
        self.like = UserDefaults.standard.value(forKey: UserDefaultsKeys.like) as? Int ?? 1
        self.likeExperience = UserDefaults.standard.value(forKey: UserDefaultsKeys.likeExperience) as? Int ?? 0
        self.likeUp = UserDefaults.standard.value(forKey: UserDefaultsKeys.likeUp) as? Int ?? 200
        self.addLike = UserDefaults.standard.value(forKey: UserDefaultsKeys.addLike) as? Int ?? 10
        self.addPoint = UserDefaults.standard.value(forKey: UserDefaultsKeys.addPoint) as? Double ?? 1
        self.addPresents = UserDefaults.standard.value(forKey: UserDefaultsKeys.addPresents) as? Int ?? 10
        self.manekineko = UserDefaults.standard.value(forKey: UserDefaultsKeys.manekineko) as? Int ?? 0
        self.mlevelUp = UserDefaults.standard.value(forKey: UserDefaultsKeys.mlevelUp) as? Int ?? 1000
        self.catTower = UserDefaults.standard.value(forKey: UserDefaultsKeys.catTower) as? Int ?? 0
        self.clevelUp = UserDefaults.standard.value(forKey: UserDefaultsKeys.mlevelUp) as? Int ?? 1000
        self.treasure = UserDefaults.standard.value(forKey: UserDefaultsKeys.treasure) as? Int ?? 0
        self.tlevelUp = UserDefaults.standard.value(forKey: UserDefaultsKeys.tlevelUp) as? Int ?? 1000
        if let savedDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastLogin) as? Date {
                self.lastLogin = savedDate
            } else {
                self.lastLogin = Date()
            }
    }

    // MARK: - ポイント関連の処理

    /// 1GBあたりのポイント量を計算
    func calculatePointsPerGB(settingDataGB: Int) {
        guard settingDataGB > 0 else { return }
        pointsPerGB = Self.maxPoints / settingDataGB
    }

    /// データ使用量に基づくポイント追加
    func calculatePoints(oneMonthData: Double) {
        let getPoints = Double(pointsPerGB) * oneMonthData
        let addition = getPoints * (addPoint / 100)
        let points = getPoints + addition
        
        guard points.isFinite else {
            alertMessage = "無効なポイント計算結果: \(points)"
            return
        }
        currentPoints = min(currentPoints + Int(points), Self.maxPoints)
    }

    /// ポイントを消費
    func consumePoints(consumptionPoints: Int)-> Bool {
        if consumptionPoints > currentPoints {
            alertMessage = "使用ポイントが不足しています。現在のポイント: \(currentPoints)"
            return false
        } else {
            currentPoints -= consumptionPoints
            alertMessage = nil
            return true
        }
    }

    /// ミッションによるポイント付与
    func missionPoints() {
        currentPoints += 5
    }

    /// 課金ポイント付与
    func billingPoints(index: Int) {
        guard Self.billingOptions.indices.contains(index) else {
            alertMessage = "無効な課金プランです。"
            return
        }
        currentPoints += Self.billingOptions[index]
    }
    ///test
    func test(){
        currentPoints += 1000
    }
    
    // MARK: - 状態関連の処理
    
    ///スタミナ追加
    func addStamina(point: Int) {
        // ポイントを消費し、成功した場合のみ処理を進める
        guard consumePoints(consumptionPoints: point) else {
            print("ポイント消費に失敗しました")
            return
        }
        // ポイントに応じたスタミナ時間を取得
        guard let feedTime = Self.feedOptions.keys.sorted(by: >).first(where: { point >= $0 }) else {
            print("指定されたポイントに該当するスタミナ時間が見つかりません")
            return
        }
        // スタミナ時間と関連プロパティを設定
        let feedTimeValue = Self.feedOptions[feedTime] ?? 24
        staminaTime = feedTimeValue
        stamina = 100
        perhourStamina = Double(100) / Double(feedTimeValue) // 時間あたりのスタミナ回復計算
    }
    
    ///1時間ずつスタミナ削減
    func curtailmentStamina(hours: Double){
        stamina = max(0,stamina - (perhourStamina * hours))
    }
    
    ///ストレス追加
    func addStress(day: Double){
        if stamina != 0{
            return
        }
        stress = min(100, stress + (5 * Int(day)))
    }
    
    ///ストレス削減
    func curtailmentStress(point: Int){
        // ポイントを消費し、成功した場合のみ処理を進める
        guard consumePoints(consumptionPoints: point) else {
            print("ポイント消費に失敗しました")
            return
        }
        stress = min(0,stress - Self.reduction)
    }
    
    ///好感度追加
    func likeAdd(point: Int){
        print("likeAdd関数")
        // ポイントを消費し、成功した場合のみ処理を進める
        guard consumePoints(consumptionPoints: point) else {
            print("ポイント消費に失敗しました")
            return
        }
        guard let gift = Self.giftOptions[point] else {
            print("無効なポイントです")
            return
        }
        let addGift = gift * (addPresents / 100)
        likeExperience += gift + addGift
        likeLevelUp()
    }
    
    //撫でたときの好感度追加
    func caressLike(){
        let add = 5 * (addLike / 100)
        likeExperience += 5 + add
        likeLevelUp()
    }
    
    ///好感度レベルアップ
    func likeLevelUp(){
        //経験値チェック
        while likeExperience >= likeUp {
            likeExperience -= likeUp
            like += 1
            likeUp += 100
        }
    }

    // MARK: - アイテムの処理

    ///招き猫(ポイントアップ)
    func manekinako(point: Int){
        // ポイントを消費し、成功した場合のみ処理を進める
        guard consumePoints(consumptionPoints: point) else {
            print("ポイント消費に失敗しました")
            return
        }
        addPoint += 0.5
        manekineko += 1
        mlevelUp += 1000
    }
    
    ///キャットタワー
    func cattower(point: Int){
        // ポイントを消費し、成功した場合のみ処理を進める
        guard consumePoints(consumptionPoints: point) else {
            print("ポイント消費に失敗しました")
            return
        }
        addLike += 1
        catTower += 1
        clevelUp += 1000
    }
    
    ///宝箱
    func Treasure(point: Int){
        // ポイントを消費し、成功した場合のみ処理を進める
        guard consumePoints(consumptionPoints: point) else {
            print("ポイント消費に失敗しました")
            return
        }
        addPresents += 1
        treasure += 1
        tlevelUp += 1000
    }
    
    // MARK: - ストアの処理
    func store(point: Int, category: String){
        if category == "feed" {
            addStamina(point: point)
        } else if category == "toys"{
            curtailmentStress(point: point)
        }else if category == "presents"{
            likeAdd(point: point)
        }
    }
    
    // MARK: - 日時計算の処理
    
    func checkDate(){
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(lastLogin) // 秒単位の経過時間
        let hoursElapsed = timeInterval / 3600.0 // 秒を時間に変換（1時間=3600秒）
        let daysElapsed = timeInterval / (3600.0 * 24.0) // 1日 = 24時間 = 86400秒
        if hoursElapsed > 0 {
            // 経過時間分だけスタミナを削減
            curtailmentStamina(hours: hoursElapsed)
            //日数分ストレスの追加
            addStress(day: daysElapsed)
            // 現在の日時を `lastLogin` に更新
            lastLogin = currentDate
        }
    }
    
    // MARK: - ユーティリティ関数

    /// UserDefaultsに保存
    private func saveToUserDefaults<T>(key: String, value: T) {
        UserDefaults.standard.set(value, forKey: key)
    }
}
