//
//  UnlockManager.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/30/22.
//

import Combine
import StoreKit

final class UnlockManager: NSObject, ObservableObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    enum RequestState {
        case loading
        case loaded(SKProduct)
        case failed(Error?)
        case purchased
        case deferred
    }
    private enum StoreError: Error {
        case invalidIdentifiers, missingProduct
    }
    
    private let dataController: DataController
    private let request: SKProductsRequest
    private var loadedProducts = [SKProduct]()
    
    init(dataController: DataController) {
        // Store the data controller we were sent.
        self.dataController = dataController
        
        // Prepare to look for our unlock product.
        let productIDs = Set(["com.transfinite.Resolve.unlock"])
        request = SKProductsRequest(productIdentifiers: productIDs)
        
        // This is required because we inherit from NSObject.
        super.init()
        SKPaymentQueue.default().add(self)
        guard !dataController.fullVersionUnlocked else { return }
        // Set ourselves up to be notified when the product request completes.
        request.delegate = self
        
        // Start the request
        request.start()
    }
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    @Published var requestState = RequestState.loading
    
    var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments()
    }
    
    func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async { [self] in
            for transaction in transactions {
                switch transaction.transactionState {
                    case .purchased, .restored:
                        self.dataController.fullVersionUnlocked = true
                        self.requestState = .purchased
                        queue.finishTransaction(transaction)
                    case .failed:
                        if let product = loadedProducts.first {
                            self.requestState = .loaded(product)
                        } else {
                            self.requestState = .failed(transaction.error)
                        }
                        queue.finishTransaction(transaction)
                    case .deferred:
                        self.requestState = .deferred
                        
                    default:
                        break
                }
            }
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            // Store the returned products for later, if we need them.
            
            self.loadedProducts = response.products
            
            guard let unlock = self.loadedProducts.first else { self.requestState = .failed(StoreError.missingProduct)
                return
                
            }
            
            if response.invalidProductIdentifiers.isEmpty == false {
                print("ALERT: Received invalid product identifiers: \(response.invalidProductIdentifiers)")
                self.requestState = .failed(StoreError.invalidIdentifiers)
                return
            }
            self.requestState = .loaded(unlock)
        }
    }
}
