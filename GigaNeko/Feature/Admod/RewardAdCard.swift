import SwiftUI
import GoogleMobileAds

class RewardAdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    @Published var rewardAd: RewardedAd?
    @Published var isAdLoading = false
    @Published var isAdReady = false
    
    static let shared = RewardAdManager()
    
    private override init() {
        super.init()
        loadAd()
    }
    
    func loadAd() {
        guard !isAdLoading else { return }
        
        isAdLoading = true
        let request = Request()
        RewardedAd.load(with: "ca-app-pub-2291273458039892/1862327728", request: request) { [weak self] ad, error in
            self?.isAdLoading = false
            if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                return
            }
            self?.rewardAd = ad
            self?.rewardAd?.fullScreenContentDelegate = self
            self?.isAdReady = true
        }
    }
    
    func showAd(completion: @escaping (Bool) -> Void) {
        guard let rewardAd = rewardAd, let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            completion(false)
            return
        }
        
        rewardAd.present(from: rootViewController) {
            completion(true)
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        isAdReady = false
        loadAd()
    }
}

struct RewardAdCard: View {
    @StateObject private var adManager = RewardAdManager.shared
    @StateObject private var giganekoPoint = GiganekoPoint.shared
    
    var body: some View {
        Button(action: {
            if adManager.isAdReady {
                adManager.showAd { success in
                    if success {
                        giganekoPoint.rewardAdPoints(adPoint: 100)
                    }
                }
            } else {
                adManager.loadAd()
            }
        }) {
            HStack {
                Image(systemName: "play.circle.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("動画を見てポイントGET!")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text("無料で100ポイントを獲得")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if adManager.isAdLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                } else {
                    Text("+100 pt")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.yellow)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .disabled(adManager.isAdLoading)
    }
}
