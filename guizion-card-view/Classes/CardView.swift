//
//  CardView.swift
//  Pods
//
//  Created by Guizion Labs on 07/07/16.
//
//

import Foundation
import UIKit
import UIColor_Hex_Swift
/**
 CardView is a iOS UI Library for Credit Card animation
 - Author: Guizion Labs
 - Version: 1.0
 */
public class CardView: UIView {
    
    public enum State {
        case Front
        case Back
    }
    
    private var frontView = CardFrontView()
    private var backView = CardBackView()
    
    private let noCardView = UIImageView(image: UIImage.loadImageFromPodBundle("no_card"))
    private let cardFormatter = CardNumberFormatter()
    private var lastCardType = CardTypes.None
    
    public var state: State = .Front
    
    /**
     Retrive the card type
     - SeeAlso: `CardTypes`
     */
    public var card: CreditCard = CreditCard()
    
    public var bundleAnimationDuration = 2.5
    public var flipAnimationDuration = 1
    
    public override func layoutSubviews() {
        noCardView.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        frontView.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        backView.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        self.addSubview(backView)
        self.addSubview(noCardView)
        self.addSubview(frontView)
        
        frontView.cardNumber.textColor = UIColor(rgba: "#D7D7D7")
        frontView.cardName.textColor = UIColor(rgba: "#D4D4D4")
        frontView.validateNumber.textColor = UIColor(rgba: "#D4D4D4")
    }
    
    /**
     Use this function to flip de credit card to the back-side
     
     - Throws: CreditCardErrors.NumberNotProvided
     
     ```
     do{
        try self.flip()
     } catch CreditCardErrors.NumberNotProvided {
     
     } catch _ {
     
     }
     ```
     */
    public func flip(onComplete: () -> Void) throws {
        
        if frontView.image == nil || backView.image == nil {
            throw CreditCardErrors.NumberNotProvided
        }
        
        let transitionOptions: UIViewAnimationOptions
        var views : (frontView: UIView, backView: UIView)
        
        if state == .Front {
            views = (frontView: frontView, backView: backView)
            transitionOptions = UIViewAnimationOptions.TransitionFlipFromRight
        } else {
            views = (frontView: backView, backView: frontView)
            transitionOptions = UIViewAnimationOptions.TransitionFlipFromLeft
        }
        
        
        UIView.transitionFromView(views.frontView,
                                  toView: views.backView,
                                  duration: 1,
                                  options: transitionOptions,
                                  completion: { [weak self] _ in
                                    
                                    self?.state = self?.state == .Front ? .Back : .Front
                                    
                                    onComplete()
                                    
        })
        
    }
    
    public func updateNumber(number: String) {
        
        frontView.cardNumber.text = number
        
        let card = self.cardFormatter.verifyPattern(number)
        self.card = card ?? self.card

        if card.cardType == .None {
            frontView.image = nil
            backView.image = nil
            noCardView.hidden = false
            
            frontView.cardNumber.textColor = UIColor(rgba: "#D7D7D7")
            frontView.cardName.textColor = UIColor(rgba: "#D4D4D4")
            frontView.validateNumber.textColor = UIColor(rgba: "#D4D4D4")

            
            return
        }
        
        if card.cardType != lastCardType {
            frontView.image = UIImage.loadImageFromPodBundle(card.card?.frontImage ?? "notrecognized_front")
            backView.image = UIImage.loadImageFromPodBundle(card.card?.backImage ?? "notrecognized_back")
            backView.ccvNumber.textColor = UIColor(rgba: card.card!.ccvColor!)
            
            frontView.cardNumber.textColor = UIColor(rgba: card.card!.numberColor!)
            frontView.cardName.textColor = UIColor(rgba: card.card!.nameColor!)
            frontView.validateNumber.textColor = UIColor(rgba: card.card!.expirationColor!)

            bubbleAnimation() { [weak self] in
                self?.noCardView.hidden = true
            }
        }
        lastCardType = card.cardType
    }
    
    public func updateCCVNumber(number: String) {
        backView.ccvNumber.text = number
    }
    
    public func updateName(name: String) {
        frontView.cardName.text = name
    }
    
    public func updateExpirationDate(date: String) {
        frontView.validateNumber.text = date
    }
    
    func bubbleAnimation(onComplete: () -> Void) {
        let maskLayer = CAShapeLayer()
        let maskRect = CGRectMake(-25, bounds.maxY - 25, 50, 50);
        let path = CGPathCreateWithEllipseInRect(maskRect, nil)
        
        let finalRect = CGRectMake(-bounds.width*2, bounds.maxY - bounds.height*2, bounds.width * 4, bounds.height * 4)
        let finalPath = CGPathCreateWithEllipseInRect(finalRect, nil)
        maskLayer.path = path
        
        frontView.layer.mask = maskLayer
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock({
            print("completed")
            onComplete()
        })
        
        let anim = CABasicAnimation(keyPath: "path")
        anim.fromValue = maskLayer.path
        anim.toValue = finalPath
        anim.duration = 2.5
        anim.removedOnCompletion = true
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        maskLayer.addAnimation(anim, forKey: nil)
        
        maskLayer.path = finalPath
        CATransaction.commit()
    }
    
}