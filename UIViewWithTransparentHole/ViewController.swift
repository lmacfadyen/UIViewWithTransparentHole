//
//  ViewController.swift
//  UIViewWithTransparentHole
//
//  Created by Lawrence F MacFadyen on 2020-05-11.
//  Copyright © 2020 Lawrence F MacFadyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var viewOpening: UIView!
    @IBOutlet weak var viewMaskArea: UIView!
    @IBOutlet weak var switchOverlay: UISwitch!

    var maskView: MaskView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchOverlay.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
    }
    
    @objc func switchValueDidChange() {
        if(switchOverlay.isOn)
        {
            addOverlay()
        }
        else {
            removeOverlay()
        }
    }
    
    @IBAction func buttonInsideTouchUp(_ sender: Any) {
        let alertController = UIAlertController(title: "Inside", message: "You pressed the Inside Button", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion:nil)
    }
    
    @IBAction func buttonOutsideTouchUp(_ sender: Any) {
        let alertController = UIAlertController(title: "Outside", message: "You pressed the Outside Button", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion:nil)
    }
    
    func addOverlay() {
        let buttonFrame = viewOpening.convert(viewOpening.bounds, to: viewMaskArea)
        maskView = MaskView(frame: viewMaskArea.bounds, opening: buttonFrame)
        if let created = maskView {
            viewMaskArea.addSubview(created)
        }
    }
    
    func removeOverlay()
    {
        guard let created = maskView else {return}
        created.removeFromSuperview()
        maskView = nil
    }
}

// UIView subclass to overlay a given CGRect with a provided CGRect opening
class MaskView: UIView {
    let opening: CGRect
    
    required init?(coder aDecoder: NSCoder) {
        preconditionFailure("Cannot initialize from coder")
    }
    
    init(frame: CGRect, opening: CGRect) {
        self.opening = opening
        super.init(frame: frame)
        customInit()
    }
    
    func customInit() {
        let color = UIColor.label
        self.backgroundColor = color.withAlphaComponent(0.8)
        self.maskLayer()
    }
    // Good techical resource for how to do the masking
    // https://www.calayer.com/core-animation/2016/05/22/cashapelayer-in-depth.html
    func maskLayer() {
        // Create the mask layer
        let maskLayer = CAShapeLayer()
        // Create a path for the whole mask area
        let wholeMaskPath = UIBezierPath(rect: self.bounds)
        // Create the rectangle opening path
        let openingPath = UIBezierPath(rect: opening)
        // Append openingPath to the wholeMaskPath
        wholeMaskPath.append(openingPath)
        // Fill rule to fill only where paths do not overlap
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        // Set path of the mask layer
        maskLayer.path = wholeMaskPath.cgPath
        // Mask our UIView with the maskLayer so only opening rectangle shows through
        self.layer.mask = maskLayer
    }
    
    // Check where an event lands to decide whether to pass through this UIView
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if(opening.contains(point))
        {
            /* return false to send event up responder chain so maskView doesn't handle event
             over the opening, and instead controls within opening
             will receive it
             */
            return false
        }
        else {
            // outside opening area so don't send event up responder chain
            return true
        }
    }
}

