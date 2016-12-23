//
//  ViewController.swift
//  eCommerceExercise
//
//  Created by Sara OC on 13/06/2015.
//  Copyright (c) 2015 Sara OC Inc. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // product collection view set up
    
    var cart = CartBrain()
    var data = ProductList()
    
    @IBOutlet weak var productCell: UICollectionView!

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.productTitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        // product cell attributes
        cell.labelNameCell.text = data.productTitle[indexPath.row]
            cell.labelNameCell.adjustsFontSizeToFitWidth = true;
        cell.labelDescriptionCell.text = data.productDescription[indexPath.row]
        cell.labelGenderCell.text = data.productGender[indexPath.row]
        cell.labelCategoryCell.text = data.productCategory[indexPath.row]
        cell.labelStockCell.text = data.productStock[indexPath.row] + " available"
        cell.imageCell.image = UIImage(named: data.productImage[indexPath.row])
        
        // product pricing with sale price logic
        cell.labelPriceCell.text = "£" + data.productPrice[indexPath.row]
        if data.productSalePrice[indexPath.row] != data.productPrice[indexPath.row] {
            cell.labelSalePrice.text = "Sale! £" + data.productSalePrice[indexPath.row]
        } else {
            cell.labelSalePrice.text = nil
        }
        
        // add/remove button logic
        cell.addToCartButton.tag = indexPath.row
        cell.addToCartButton.addTarget(self, action: #selector(ProductViewController.addToCart(_:)), for: .touchUpInside)
        
        cell.removeFromCartButton.isHidden = true
        cell.removeFromCartButton.tag = indexPath.row
        cell.removeFromCartButton.addTarget(self, action: #selector(ProductViewController.removeFromCart(_:)), for: .touchUpInside)
        
        if cart.cartProducts.contains( indexPath.row) {
            cell.removeFromCartButton.isHidden = false
            cell.addToCartButton.isHidden = true
        } else {
            cell.removeFromCartButton.isHidden = true
            cell.addToCartButton.isHidden = false
        }
        
        // decorative line
        cell.imageBorderCell.image = UIImage(named: "line.png")
        
        return cell
    }
    
    // add and remove from cart
    @IBOutlet weak var productErrorMessage: UILabel!
    
    func addToCart(_ sender: UIButton) {
        let selectedProduct = sender.tag
        productErrorMessage.text = ""
        self.checkStock(selectedProduct)
        updateCartDisplay()
        productCell.reloadData()
    }
    
    func removeFromCart(_ sender: UIButton) {
        let selectedProduct = sender.tag
        cart.removeObject(object: selectedProduct, array: &cart.cartProducts)
        checkVouchersAgain()
        returnStock(selectedProduct)
        updateCartDisplay()
        productCell.reloadData()
    }
    
    // stock logic
    func checkStock(_ selectedProduct: Int) {
        let resultOfStockCheck = cart.checkStock(selectedProduct)
        
        if resultOfStockCheck.accepted {
            cart.cartProducts.append(selectedProduct)
            data.productStock = resultOfStockCheck.newStockList
        } else {
            productErrorMessage.text = "This item is out of stock."
        }
    }
    
    func returnStock(_ selectedProduct: Int) {
        let resultOfReturnStock = cart.returnStock(selectedProduct)
        data.productStock = resultOfReturnStock
    }
    
    // removing product requires voucher check
    func checkVouchersAgain() {
        for item in cart.cartVouchers {
            if cart.checkVoucher(item) == false {
                cart.removeObject(object: item, array: &cart.cartVouchers)
            }
        }
    }
    
    // shopping bag "cart" display
    @IBOutlet weak var cartButton: UIButton!
    @IBOutlet weak var cartTotalDisplay: UILabel!
    
    func updateCartDisplay() {
        cartButton.setTitle("\(cart.cartProducts.count)", for: UIControlState())
        cart.totalCart()
        cartTotalDisplay.text = "£" + String.localizedStringWithFormat("%.2f", cart.total)
    }
    
    // pass cart data between views
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "segueToVouchers") {
            let svc = segue.destination as! VoucherViewController;
            
            svc.passedTotal = cartTotalDisplay.text
            svc.passedCartContents = cart.cartProducts
            svc.passedVouchers = cart.cartVouchers
        }
    }
    
    var passedTotalFromVouchers:String!
    var passedCartContentsFromVouchers:[Int]!
    var passedCartVouchersFromVouchers:[Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if passedTotalFromVouchers != nil {
            cartTotalDisplay.text = passedTotalFromVouchers
            cartButton.setTitle("\(passedCartContentsFromVouchers.count)", for: UIControlState())
            cart.cartProducts = passedCartContentsFromVouchers
            cart.cartVouchers = passedCartVouchersFromVouchers
        }
    }


}


