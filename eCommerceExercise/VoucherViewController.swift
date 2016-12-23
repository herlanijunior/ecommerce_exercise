//
//  VoucherViewController.swift
//  eCommerceExercise
//
//  Created by Sara OC on 17/06/2015.
//  Copyright (c) 2015 Sara OC Inc. All rights reserved.
//

import UIKit

class VoucherViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // voucher collection view set up
    
    var data = VoucherList()

    @IBOutlet weak var voucherCollection: UICollectionView!

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.voucherDisplayCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let voucherCell = collectionView.dequeueReusableCell(withReuseIdentifier: "voucherCell", for: indexPath) as! VoucherCollectionViewCell
        
        voucherCell.voucherCategory.text = data.voucherDisplayCategory[indexPath.row]
        voucherCell.voucherConditions.text = data.voucherConditionDescription[indexPath.row]
        voucherCell.voucherImage.image = UIImage(named: data.voucherImage[indexPath.row])
        
        voucherCell.addToCartButton.tag = indexPath.row
        voucherCell.addToCartButton.addTarget(self, action: #selector(VoucherViewController.addToCart(_:)), for: .touchUpInside)
        
        voucherCell.removeFromCartButton.isHidden = true
        voucherCell.removeFromCartButton.tag = indexPath.row
        voucherCell.removeFromCartButton.addTarget(self, action: #selector(VoucherViewController.removeFromCart(_:)), for: .touchUpInside)
        
        if cart.cartVouchers.contains( indexPath.row) {
            voucherCell.removeFromCartButton.isHidden = false
            voucherCell.addToCartButton.isHidden = true
        } else {
            voucherCell.removeFromCartButton.isHidden = true
            voucherCell.addToCartButton.isHidden = false
        }
        
        return voucherCell
    }
    
    // add and remove vouchers
    var cart = CartBrain()
    @IBOutlet weak var voucherErrorMessage: UILabel!
    
    func addToCart(_ sender: UIButton) {
        let selectedVoucher = sender.tag
        voucherErrorMessage.text = ""
        self.checkVoucher(selectedVoucher)
        updateCartDisplay()
        voucherCollection.reloadData()
    }
    
    func removeFromCart(_ sender: UIButton) {
        let selectedVoucher = sender.tag
        cart.removeObject(object: selectedVoucher, array: &cart.cartVouchers)
        updateCartDisplay()
        voucherCollection.reloadData()
    }
    
    // check voucher
    func checkVoucher(_ selectedVoucher: Int) {
        if cart.checkVoucher(selectedVoucher) {
            cart.cartVouchers.append(selectedVoucher)
        } else {
            voucherErrorMessage.text = "Your order doesn't qualify for this voucher."
        }
    }
    
    // shopping bag "cart" display
    @IBOutlet weak var cartItemCount: UIButton!
    @IBOutlet weak var cartTotal: UILabel!

    func updateCartDisplay() {
        cartItemCount.setTitle("\(cart.cartProducts.count)", for: UIControlState())
        cart.totalCart()
        cartTotal.text = "£" + String.localizedStringWithFormat("%.2f", cart.total)
    }
    
    // passing cart data between views
    var passedTotal:String!
    var passedCartContents:[Int]!
    var passedVouchers:[Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if passedTotal != nil {
            cartTotal.text = passedTotal
            cart.cartProducts = passedCartContents
            cartItemCount.setTitle("\(cart.cartProducts.count)", for: UIControlState())
        }
        
        if passedVouchers != nil {
            cart.cartVouchers = passedVouchers
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "segueFromVouchers") {
            let svc = segue.destination as! ProductViewController;
            
            svc.passedTotalFromVouchers = cartTotal.text
            svc.passedCartContentsFromVouchers = cart.cartProducts
            svc.passedCartVouchersFromVouchers = cart.cartVouchers
            
        }
    }

}
