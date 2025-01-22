import SwiftUI

struct HeartParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat
    var opacity: Double
    var rotation: Double
    var offset: CGSize
}

class ParticleSystem: ObservableObject {
    @Published var particles: [HeartParticle] = []
    private var lastParticleTime: Date = Date()
    private let particleInterval: TimeInterval = 1.0  // パーティクル生成間隔
    
    func createRisingHearts(in frame: CGRect) {
        let now = Date()
        if now.timeIntervalSince(lastParticleTime) >= particleInterval {
            let baseX = frame.midX
            let baseY = frame.midY - 50
            
            // 3つのハートを生成（左、中央、右）
            let positions = [
                CGPoint(x: baseX - 25, y: baseY),
                CGPoint(x: baseX, y: baseY - 10),
                CGPoint(x: baseX + 25, y: baseY)
            ]
            
            for position in positions {
                let particle = HeartParticle(
                    position: position,
                    scale: CGFloat.random(in: 1.5...2.0),  // 大きめのサイズ
                    opacity: 1,
                    rotation: 0,  // 回転なし
                    offset: .zero
                )
                particles.append(particle)
            }
            
            lastParticleTime = now
            
            // シンプルな上昇アニメーション
            withAnimation(.easeOut(duration: 5.0)) {  // アニメーション時間2秒
                for i in particles.indices.suffix(3) {
                    particles[i].offset = CGSize(
                        width: 0,        // 横移動なし
                        height: -400     // まっすぐ上に移動
                    )
                    particles[i].opacity = 0  // フェードアウト
                }
            }
            
            // アニメーション後にパーティクルを削除
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.particles.removeAll { particle in
                    particle.opacity == 0
                }
            }
        }
    }
}
