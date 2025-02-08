//////GiganekoPoint.swift//////////
import Foundation

class GiganekoPoint: ObservableObject {
    
    static let shared = GiganekoPoint()
    
    // MARK: - 公開プロパティ
    ///現在のポイント
    @Published var currentPoints: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.currentPoints, value: currentPoints) }
    }
    
    ///実行したかフラグ
    @Published var isAlreadyExecuted: Bool {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.isAlreadyExecuted, value: isAlreadyExecuted) }
    }
    
    ///最後実行した月
    @Published var lastExecutedMonth: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.lastExecutedMonth, value: lastExecutedMonth) }
    }
    
    ///スタミナ
    @Published var stamina: Double {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.stamina, value: stamina) }
    }
    ///スタミナ持続時間
    @Published var staminaTime: Double {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.staminaTime, value: staminaTime) }
    }
    
    //スタミナ時間
    @Published var staminaHours: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.staminaHours, value: staminaHours) }
    }
    
    //スタミナ分
    @Published var staminaMinutes: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.staminaMinutes, value: staminaMinutes) }
    }
    
    //スタミナ秒
    @Published var staminaSeconds: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.staminaSeconds, value: staminaSeconds) }
    }
    ///一時間あたりのスタミナ
    @Published var maxStamina: Double {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.maxStamina, value: maxStamina) }
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
        didSet { saveToUserDefaults(key: UserDefaultsKeys.likeExperience, value: likeExperience) }
    }
    ///好感度レベルアップに必要な経験値
    @Published var likeUp: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.likeUp, value: likeUp) }
    }
    ///キャットタワー効果ポイント
    @Published var addLike: Double {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.addLike, value: addLike) }
    }
    ///招き猫効果のポイント
    @Published var addPoint: Double {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.addPoint, value: addPoint) }
    }
    ///宝箱効果のポイント
    @Published var addPresents: Double {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.addPresents, value: addPresents) }
    }
    ///招き猫レベル
    @Published var manekineko: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.manekineko, value: manekineko) }
    }
    ///招き猫をレベルUPに必要なポイント
    @Published var mlevelUp: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.mlevelUp, value: mlevelUp) }
    }
    ///キャットタワーレベル
    @Published var catTower: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.catTower, value: catTower) }
    }
    ///キャットタワーレベルUPに必要なポイント
    @Published var clevelUp: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.clevelUp, value: clevelUp) }
    }
    ///宝箱レベル
    @Published var treasure: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.treasure, value: treasure) }
    }
    ///宝箱レベルUPに必要なポイント
    @Published var tlevelUp: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.tlevelUp, value: tlevelUp) }
    }
    ///最終ログイン
    @Published var lastLogin: Date {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.lastLogin, value: lastLogin) }
    }
    ///ログインチェック
    @Published var dateCheck: Int {
        didSet { saveToUserDefaults(key: UserDefaultsKeys.dateCheck, value: dateCheck) }
    }
    @Published var alertMessage: String?

    // MARK: - 定数
    private static let maxPoints = 5000 // 一ヶ月にもらえる最大のポイント数
    private static let billingOptions = [120, 630, 1320, 2760, 5760, 12000] // 課金ポイント量
    private static let feedOptions = [0: 24, 100: 48, 200: 72, 900: 240] // 必要ポイント: スタミナ時間
    private static let giftOptions = [1000: 100, 5000: 500, 8000: 1000] // 必要ポイント: 好感度
    private static let reduction = 20 //ストレス削減値

    // UserDefaultsキー
    private struct UserDefaultsKeys {
        static let currentPoints = "GiganekoPoint.currentPoints"
        static let isAlreadyExecuted = "GiganekoPoint.isAlreadyExecuted"
        static let lastExecutedMonth = "GiganekoPoint.lastExecutedMonth"
        static let stamina = "GiganekoPoint.stamina"
        static let staminaTime = "GiganekoPoint.staminaTime"
        static let staminaHours = "GiganekoPoint.staminaHours"
        static let staminaMinutes = "GiganekoPoint.staminaMinutes"
        static let staminaSeconds = "GiganekoPoint.staminaSeconds"
        static let maxStamina = "GiganekoPoint.maxStamina"
        static let stress = "GiganekoPoint.stress"
        static let like = "GiganekoPoint.like"
        static let likeExperience = "GiganekoPoint.likeExperience"
        static let likeUp = "GiganekoPoint.likeUp"
        static let addLike = "GiganekoPoint.addLike"
        static let addPoint = "GiganekoPoint.addPoint"
        static let addPresents = "GiganekoPoint.addPresents"
        static let manekineko = "GiganekoPoint.manekineko"
        static let mlevelUp = "GiganekoPoint.mlevelUp"
        static let catTower = "GiganekoPoint.catTower"
        static let clevelUp = "GiganekoPoint.mlevelUp"
        static let treasure = "GiganekoPoint.treasure"
        static let tlevelUp = "GiganekoPoint.mlevelUp"
        static let lastLogin = "GiganekoPoint.lastLogin"
        static let dateCheck = "GiganekoPoint.dateheck"
    }

    // MARK: - 初期化
    init() {
        // プロパティを直接初期化
        self.currentPoints = UserDefaults.shared.value(forKey: UserDefaultsKeys.currentPoints) as? Int ?? 1000
        self.isAlreadyExecuted = UserDefaults.shared.value(forKey: UserDefaultsKeys.isAlreadyExecuted) as? Bool ?? false
        self.lastExecutedMonth = UserDefaults.shared.value(forKey: UserDefaultsKeys.lastExecutedMonth) as? Int ?? 0
        self.stamina = UserDefaults.shared.value(forKey: UserDefaultsKeys.stamina) as? Double ?? 50.0
        self.staminaTime = UserDefaults.shared.value(forKey: UserDefaultsKeys.staminaTime) as? Double ?? 24.0
        self.staminaHours = UserDefaults.shared.value(forKey: UserDefaultsKeys.staminaHours) as? Int ?? 0
        self.staminaMinutes = UserDefaults.shared.value(forKey: UserDefaultsKeys.staminaMinutes) as? Int ?? 0
        self.staminaSeconds = UserDefaults.shared.value(forKey: UserDefaultsKeys.staminaSeconds) as? Int ?? 0
        self.maxStamina = UserDefaults.shared.value(forKey: UserDefaultsKeys.maxStamina) as? Double ?? 24.0
        self.stress = UserDefaults.shared.value(forKey: UserDefaultsKeys.stress) as? Int ?? 0
        self.like = UserDefaults.shared.value(forKey: UserDefaultsKeys.like) as? Int ?? 1
        self.likeExperience = UserDefaults.shared.value(forKey: UserDefaultsKeys.likeExperience) as? Int ?? 0
        self.likeUp = UserDefaults.shared.value(forKey: UserDefaultsKeys.likeUp) as? Int ?? 200
        self.addLike = UserDefaults.shared.value(forKey: UserDefaultsKeys.addLike) as? Double ?? 1.0
        self.addPoint = UserDefaults.shared.value(forKey: UserDefaultsKeys.addPoint) as? Double ?? 1.0
        self.addPresents = UserDefaults.shared.value(forKey: UserDefaultsKeys.addPresents) as? Double ?? 1.0
        self.manekineko = UserDefaults.shared.value(forKey: UserDefaultsKeys.manekineko) as? Int ?? 1
        self.mlevelUp = UserDefaults.shared.value(forKey: UserDefaultsKeys.mlevelUp) as? Int ?? 1000
        self.catTower = UserDefaults.shared.value(forKey: UserDefaultsKeys.catTower) as? Int ?? 1
        self.clevelUp = UserDefaults.shared.value(forKey: UserDefaultsKeys.mlevelUp) as? Int ?? 1000
        self.treasure = UserDefaults.shared.value(forKey: UserDefaultsKeys.treasure) as? Int ?? 1
        self.tlevelUp = UserDefaults.shared.value(forKey: UserDefaultsKeys.tlevelUp) as? Int ?? 1000
        if let savedDate = UserDefaults.shared.object(forKey: UserDefaultsKeys.lastLogin) as? Date {
            self.lastLogin = savedDate
        } else {
            self.lastLogin = Date()
        }
        self.dateCheck = UserDefaults.shared.object(forKey: UserDefaultsKeys.dateCheck) as? Int ?? 0
        
        resetExecutedFlagIfNeeded()
    }

    // MARK: - ポイント関連の処理
    
    ///インストールされた月のポイント計算
    /// 通信量分のポイント追加
    func CalculatePoints(settingDataGB: Int) {
        // 初日チェック＆既に実行済みか確認
        guard checkLastDayOfMonth(), !isAlreadyExecuted else { return }
        
        // 使った通信量取得
        let (_, wwan) = getCurrentMonthUsage()
        
        // 残りの通信量割合を計算（節約割合）
        let savedRate = 1 - (wwan / Double(settingDataGB))
        
        // 付与ポイントの計算を分割
        let adjustmentFactor = 1 / Double(settingDataGB)
        let basePoints = Double(GiganekoPoint.maxPoints) * savedRate * adjustmentFactor * 10
        
        // ボーナスポイント計算
        let addition = basePoints * (addPoint / 100)
        
        // 総ポイントを計算
        let totalPoints = basePoints + addition
        
        // ポイントを加算
        currentPoints += Int(totalPoints)
        
        // 実行済みフラグを更新
        isAlreadyExecuted = true
        lastExecutedMonth = Calendar.current.component(.month, from: Date())

        print("データ使用量に基づくポイント追加: \(Int(totalPoints))pt")
    }

    
    /// 月の最終日かどうかをチェック
    func checkLastDayOfMonth() -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()
            
        // 当月の最終日を取得
        if let lastDayOfMonth = calendar.date(from: DateComponents(
            year: calendar.component(.year, from: currentDate),
            month: calendar.component(.month, from: currentDate) + 1,
            day: 1)) {
            let isLastDay = calendar.isDate(currentDate, inSameDayAs: lastDayOfMonth)
            return isLastDay
        }
        return false
    }
    
    /// 月が変わったらisAlreadyExecutedをリセット
    func resetExecutedFlagIfNeeded() {
        let currentMonth = Calendar.current.component(.month, from: Date())
            
        if lastExecutedMonth != currentMonth {
            isAlreadyExecuted = false
            lastExecutedMonth = currentMonth
        }
    }
    
    /// ポイントを消費
    func consumePoints(consumptionPoints: Int)-> Bool {
        if consumptionPoints > currentPoints {
            alertMessage = "使用ポイントが不足しています。現在のポイント: \(currentPoints)"
            return false
        } else {
            currentPoints = currentPoints - consumptionPoints
            alertMessage = nil
            return true
        }
    }

    /// ログインによるポイント付与
    func loginPoints() {
        let currentDate = Calendar.current.component(.day, from: Date())
            
        if dateCheck != currentDate {
            currentPoints += 20
            dateCheck = currentDate
        }
    }

    /// 課金ポイント付与
    func billingPoints(index: Int) {
        guard Self.billingOptions.indices.contains(index) else {
            alertMessage = "無効な課金プランです。"
            return
        }
        print(currentPoints)
        currentPoints += Self.billingOptions[index]
        print(currentPoints)
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
        staminaTime = Double(feedTimeValue)
        stamina = 100
        maxStamina = Double(feedTimeValue)
    }
    
    ///スタミナ削減
    func curtailmentStamina(hours: Double){
        staminaTime = max(0, staminaTime - hours)
        let totalSeconds = Int(staminaTime * 3600) // 時間を秒に変換
        staminaHours = totalSeconds / 3600
        staminaMinutes = (totalSeconds % 3600) / 60
        staminaSeconds = totalSeconds % 60 
        stamina = (staminaTime / maxStamina) * 100.0
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
        stress = max(0,stress - Self.reduction)
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
        let addGift = Double(gift) * (addPresents / 100)
        likeExperience += gift + Int(addGift)
        likeLevelUp()
    }
    
    //撫でたときの好感度追加
    func caressLike(){
        let add = 5 * (addLike / 100)
        likeExperience += 5 + Int(add)
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
        addLike += 0.5
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
        addPresents += 0.5
        treasure += 1
        tlevelUp += 1000
    }
    
    func furniture(point: Int, category: String){
        if category == "招き猫" {
            manekinako(point: point)
        } else if category == "キャットタワー"{
            cattower(point: point)
        }else if category == "宝箱"{
            Treasure(point: point)
        }
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
        UserDefaults.shared.set(value, forKey: key)
    }
    
    // MARK: - 他のクラス用処理
    
    func updateStaminaTime() {
        let totalSeconds = Int(staminaTime * 3600) // 時間を秒に変換
        staminaHours = totalSeconds / 3600
        staminaMinutes = (totalSeconds % 3600) / 60
        staminaSeconds = totalSeconds % 60
    }
}
