import SwiftUI
import StoreKit

@MainActor
class PurchaseManager: ObservableObject {
    @Published var isProcessingPayment = false
    var onPurchaseSuccess: (() -> Void)?
    
    init() {
        listenForTransactions()
    }
    
    private func listenForTransactions() {
        Task {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    // トランザクションが検証された場合の処理
                    await transaction.finish()
                    print("Transaction verified for product: \(transaction.productID)")
                case .unverified(let transaction, let error):
                    // トランザクションの検証に失敗した場合の処理
                    await transaction.finish()
                    print("Transaction unverified: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func purchaseProduct(productId: String) {
        isProcessingPayment = true
        Task {
            do {
                let product = try await Product.products(for: [productId]).first!
                let result = try await product.purchase()
                
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        await transaction.finish()
                        print("Purchase successful for product: \(productId)")
                        // 購入成功時にコールバックを呼び出す
                        onPurchaseSuccess?()
                        
                    case .unverified(let transaction, let error):
                        await transaction.finish()
                        print("Purchase failed due to verification error: \(error.localizedDescription)")
                    }
                case .userCancelled:
                    print("User cancelled the purchase.")
                default:
                    print("Purchase failed or pending.")
                }
            } catch {
                print("Purchase failed with error: \(error.localizedDescription)")
            }
            isProcessingPayment = false
        }
    }
}
