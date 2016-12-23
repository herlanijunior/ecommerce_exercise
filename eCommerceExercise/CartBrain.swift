//
//  CartBrain.swift
//  eCommerceExercise
//
//  Created by Sara OC on 14/06/2015.
//  Copyright (c) 2015 Sara OC Inc. All rights reserved.
//

import Foundation

class CartBrain {
    
    var cartProducts = [Int]()
    var cartVouchers = [Int]()
    var productData = ProductList()
    var voucherData = VoucherList()
    
    func removeObject<T : Equatable>( object: T,  array: inout [T])
    {
        let index = array.index( of: object)
        array.remove(at: index!)
    }

    func checkStock(_ selectedProduct: Int) -> (newStockList: [String], accepted: Bool) {
        var result: (newStockList:[String], accepted: Bool)
        
        result.newStockList = []
        result.accepted = false
        
        let availableStock = Int(productData.productStock[selectedProduct])
        
        if availableStock! > 0 {
            productData.productStock[selectedProduct] = "\(availableStock! - 1)"
            result.newStockList = productData.productStock
            result.accepted = true
            
        } else {
            result.accepted = false
        }
        
        return result
    }
    
    var total: Float = 0
    var productTotal: Float = 0
    var voucherTotal: Float = 0
    
    func totalCart() {
        productTotal = 0
        voucherTotal = 0
        for item in cartProducts {
            productTotal += (productData.productSalePrice[item] as NSString).floatValue
        }
        for item in cartVouchers {
            voucherTotal += (voucherData.voucherMoneyOff[item])
        }
        total = productTotal - voucherTotal
    }
    
    func checkVoucher(_ selectedVoucher: Int) -> Bool {
        var accepted: Bool = false
        totalCart()
        if Int(productTotal) > voucherData.voucherMinimum[selectedVoucher] {
            accepted = true
        } else {
            accepted = false
        }
        
        if voucherData.voucherRequiredProductCategory[selectedVoucher] != "" {
            var cartCategories = [String]()
            for item in cartProducts {
                cartCategories.append(productData.productCategory[item])
            }
            let categoryToMatch = voucherData.voucherRequiredProductCategory[selectedVoucher]
            
            if cartCategories.index( of: categoryToMatch) != nil && accepted != false {
                accepted = true
            } else {
                accepted = false
            }
        }

        return accepted
    }
    
    func returnStock(_ selectedProduct: Int) -> [String] {
        let availableStock = Int((productData.productStock[selectedProduct]))!
        productData.productStock[selectedProduct] = "\(availableStock + 1)"
        return productData.productStock
    }

}
