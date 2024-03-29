//  SCLAlertView.swift
//  SCLAlertView Example
//
//  Created by Viktor Radchenko on 6/5/14.
//  Copyright (c) 2014 Viktor Radchenko. All rights reserved.
//
// https://github.com/vikmeup/SCLAlertView-Swift

import Foundation
import UIKit

// Pop Up Styles
enum SCLAlertViewStyle {
    case Success, Error, Notice, Warning, Info, Edit
}

// Action Types
enum SCLActionType {
    case None, Selector, Closure
}

// Button sub-class
class SCLButton: UIButton {
    var actionType = SCLActionType.None
    var target:AnyObject!
    var selector:Selector!
    var action:(()->Void)!
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
    }
}

// Allow alerts to be closed/renamed in a chainable manner
// Example: SCLAlertView().showSuccess(self, title: "Test", subTitle: "Value").close()
class SCLAlertViewResponder {
    let alertview: SCLAlertView
    
    // Initialisation and Title/Subtitle/Close functions
    init(alertview: SCLAlertView) {
        self.alertview = alertview
    }
    
    func setTitle(title: String) {
        self.alertview.labelTitle.text = title
    }
    
    func setSubTitle(subTitle: String) {
        self.alertview.viewText.text = subTitle
    }
    
    func close() {
        self.alertview.hideView()
    }
}

let kCircleHeightBackground: CGFloat = 62.0

// The Main Class
class SCLAlertView: UIViewController {
    let kDefaultShadowOpacity: CGFloat = 0.7
    let kCircleTopPosition: CGFloat = -12.0
    let kCircleBackgroundTopPosition: CGFloat = -15.0
    let kCircleHeight: CGFloat = 56.0
    let kCircleIconHeight: CGFloat = 20.0
    let kTitleTop:CGFloat = 24.0
    let kTitleHeight:CGFloat = 40.0
    let kWindowWidth: CGFloat = 240.0
    var kWindowHeight: CGFloat = 178.0
    var kTextHeight: CGFloat = 90.0
    
    // Font
    let kDefaultFont = "HelveticaNeue"
    let kButtonFont = "HelveticaNeue-Bold"
    
    // Members declaration
    var labelTitle = UILabel()
    var viewText = UITextView()
    var contentView = UIView()
    var circleBG = UIView(frame:CGRect(x:0, y:0, width:kCircleHeightBackground, height:kCircleHeightBackground))
    var circleView = UIView()
    var circleIconImageView = UIImageView()
    var durationTimer: Timer!
    private var inputs = [UITextField]()
    private var buttons = [SCLButton]()
    
    var parentView: UIView?;
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    required init() {
        super.init(nibName: "", bundle: nil)
        // Set up main view
        self.view.frame = UIScreen.main.bounds
        self.view.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.view.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:kDefaultShadowOpacity)
        self.view.addSubview(contentView)
        // Content View
        contentView.backgroundColor = UIColor(white:1, alpha:1)
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 0.5
        contentView.addSubview(labelTitle)
        contentView.addSubview(viewText)
        // Circle View
        circleBG.backgroundColor = UIColor.white
        circleBG.layer.cornerRadius = circleBG.frame.size.height / 2
        view.addSubview(circleBG)
        circleBG.addSubview(circleView)
        circleView.addSubview(circleIconImageView)
        var x = (kCircleHeightBackground - kCircleHeight) / 2
        circleView.frame = CGRect(x:x, y:x, width:kCircleHeight, height:kCircleHeight)
        circleView.layer.cornerRadius = circleView.frame.size.height / 2
        x = (kCircleHeight - kCircleIconHeight) / 2
        circleIconImageView.frame = CGRect(x:x, y:x, width:kCircleIconHeight, height:kCircleIconHeight)
        // Title
        labelTitle.numberOfLines = 1
        labelTitle.textAlignment = .center
        labelTitle.font = UIFont(name: kDefaultFont, size:20)
        labelTitle.frame = CGRect(x:12, y:kTitleTop, width: kWindowWidth - 24, height:kTitleHeight)
        // View text
        viewText.isEditable = false
        viewText.textAlignment = .center
//        viewText.textContainerInset = UIEdgeInsetsZero
        viewText.textContainer.lineFragmentPadding = 0;
        viewText.font = UIFont(name: kDefaultFont, size:14)
        // Colours
        contentView.backgroundColor = UIColorFromRGB(rgbValue: 0xFFFFFF)
        labelTitle.textColor = UIColorFromRGB(rgbValue: 0x4D4D4D)
        viewText.textColor = UIColorFromRGB(rgbValue: 0x4D4D4D)
        contentView.layer.borderColor = UIColorFromRGB(rgbValue: 0xCCCCCC).cgColor
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    convenience init(parent: UIView)
    {
        self.init();
        self.parentView = parent;
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var sz = UIScreen.main.bounds.size
        let sver = UIDevice.current.systemVersion as NSString
        let ver = sver.floatValue
        if ver < 8.0 {
            // iOS versions before 7.0 did not switch the width and height on device roration
            if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
                let ssz = sz
                sz = CGSize(width:ssz.height, height:ssz.width)
            }
        }
        // Set background frame
        view.frame.size = sz
        // Set frames
        var x = (sz.width - kWindowWidth) / 2
        var y = (sz.height - kWindowHeight -  (kCircleHeight / 8)) / 2
        contentView.frame = CGRect(x:x, y:y, width:kWindowWidth, height:kWindowHeight)
        y -= kCircleHeightBackground * 0.6
        x = (sz.width - kCircleHeightBackground) / 2
        circleBG.frame = CGRect(x:x, y:y, width:kCircleHeightBackground, height:kCircleHeightBackground)
        // Subtitle
        y = kTitleTop + kTitleHeight
        viewText.frame = CGRect(x:12, y:y, width: kWindowWidth - 24, height:kTextHeight)
        // Text fields
        y += kTextHeight + 14.0
        for txt in inputs {
            txt.frame = CGRect(x:12, y:y, width:kWindowWidth - 24, height:30)
            txt.layer.cornerRadius = 3
            y += 40
        }
        // Buttons
        for btn in buttons {
            btn.frame = CGRect(x:12, y:y, width:kWindowWidth - 24, height:35)
            btn.layer.cornerRadius = 3
            y += 45.0
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (event!.touches(for: view)?.count)! > 0 {
            view.endEditing(true)
        }
    }
    
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        if (event!.touches(for: view)?.count)! > 0 {
//            view.endEditing(true)
//        }
//    }
    
    func addTextField(title:String?=nil)->UITextField {
        // Update view height
        kWindowHeight += 40.0
        // Add text field
        let txt = UITextField()
        txt.borderStyle = UITextBorderStyle.roundedRect
        txt.font = UIFont(name:kDefaultFont, size: 14)
        txt.autocapitalizationType = UITextAutocapitalizationType.words
        txt.clearButtonMode = UITextFieldViewMode.whileEditing
        txt.layer.masksToBounds = true
        txt.layer.borderWidth = 1.0
        if title != nil {
            txt.placeholder = title!
        }
        contentView.addSubview(txt)
        inputs.append(txt)
        return txt
    }
    
    func addButton(title:String, action:@escaping ()->Void)->SCLButton {
        let btn = addButton(title: title)
        btn.actionType = SCLActionType.Closure
        btn.action = action
        btn.addTarget(self, action:Selector(("buttonTapped:")), for:.touchUpInside)
        return btn
    }
    
    func addButton(title:String, target:AnyObject, selector:Selector)->SCLButton {
        let btn = addButton(title: title)
        btn.actionType = SCLActionType.Selector
        btn.target = target
        btn.selector = selector
        btn.addTarget(self, action:Selector(("buttonTapped:")), for:.touchUpInside)
        return btn
    }
    
    private func addButton(title:String)->SCLButton {
        // Update view height
        kWindowHeight += 45.0
        // Add button
        let btn = SCLButton()
        btn.layer.masksToBounds = true
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont(name:kButtonFont, size: 14)
        contentView.addSubview(btn)
        buttons.append(btn)
        return btn
    }
    
    func buttonTapped(btn:SCLButton) {
        if btn.actionType == SCLActionType.Closure {
            btn.action()
        } else if btn.actionType == SCLActionType.Selector {
            let ctrl = UIControl()
            ctrl.sendAction(btn.selector, to:btn.target, for:nil)
        } else {
            print("Unknow action type for button")
        }
        hideView()
    }
    
    // showSuccess(view, title, subTitle)
    func showSuccess(title: String, subTitle: String, closeButtonTitle:String?=nil, duration:TimeInterval=0.0) -> SCLAlertViewResponder {
//        return showTitle(title, subTitle: subTitle, duration: duration, completeText:closeButtonTitle, style: .Success)
        
        return showTitle(title: title, subTitle: subTitle, duration: duration, completeText: closeButtonTitle, style: .Success)
        
    }
    
    // showError(view, title, subTitle)
    func showError(title: String, subTitle: String, closeButtonTitle:String?=nil, duration:TimeInterval=0.0) -> SCLAlertViewResponder {
//        return showTitle(title, subTitle: subTitle, duration: duration, completeText:closeButtonTitle, style: .Error)
          return showTitle(title: title, subTitle: subTitle, duration: duration, completeText: closeButtonTitle, style: .Error)
    }
    
    // showNotice(view, title, subTitle)
    func showNotice(title: String, subTitle: String, closeButtonTitle:String?=nil, duration:TimeInterval=0.0) -> SCLAlertViewResponder {
//        return showTitle(title, subTitle: subTitle, duration: duration, completeText:closeButtonTitle, style: .Notice)
          return showTitle(title: title, subTitle: subTitle, duration: duration, completeText: closeButtonTitle, style: .Notice)
    }
    
    // showWarning(view, title, subTitle)
    func showWarning(title: String, subTitle: String, closeButtonTitle:String?=nil, duration:TimeInterval=0.0) -> SCLAlertViewResponder {
//        return showTitle(title, subTitle: subTitle, duration: duration, completeText:closeButtonTitle, style: .Warning)
          return showTitle(title: title, subTitle: subTitle, duration: duration, completeText: closeButtonTitle, style: .Warning)
    }
    
    // showInfo(view, title, subTitle)
    func showInfo(title: String, subTitle: String, closeButtonTitle:String?=nil, duration:TimeInterval=0.0) -> SCLAlertViewResponder {
//        return showTitle(title, subTitle: subTitle, duration: duration, completeText:closeButtonTitle, style: .Info)
          return showTitle(title: title, subTitle: subTitle, duration: duration, completeText: closeButtonTitle, style: .Info)
    }
    
    func showEdit(title: String, subTitle: String, closeButtonTitle:String?=nil, duration:TimeInterval=0.0) -> SCLAlertViewResponder {
//        return showTitle(title, subTitle: subTitle, duration: duration, completeText:closeButtonTitle, style: .Edit)
          return showTitle(title: title, subTitle: subTitle, duration: duration, completeText: closeButtonTitle, style: .Edit)
    }
    
    // showTitle(view, title, subTitle, style)
    func showTitle(title: String, subTitle: String, style: SCLAlertViewStyle, closeButtonTitle:String?=nil, duration:TimeInterval=0.0) -> SCLAlertViewResponder {
//        return showTitle(title, subTitle: subTitle, duration:duration, completeText:closeButtonTitle, style: style)
          return showTitle(title: title, subTitle: subTitle, duration: duration, completeText: closeButtonTitle, style: style)
    }
    
    // showTitle(view, title, subTitle, duration, style)
    func showTitle(title: String, subTitle: String, duration: TimeInterval?, completeText: String?, style: SCLAlertViewStyle) -> SCLAlertViewResponder {
        view.alpha = 0
        //let rv = UIApplication.sharedApplication().keyWindow?.subviews.first as UIView
        //let rv = UIApplication.sharedApplication().delegate?.window??.subviews.first as UIView;
        
        let rv = self.parentView!;
        rv.addSubview(view);
        
        view.frame = rv.bounds
        
        // Alert colour/icon
        var viewColor = UIColor()
        var iconImage: UIImage
        
        // Icon style
        switch style {
        case .Success:
            viewColor = UIColorFromRGB(rgbValue: 0x22B573)
            iconImage = SCLAlertViewStyleKit.imageOfCheckmark
            
        case .Error:
            viewColor = UIColorFromRGB(rgbValue: 0xC1272D)
            iconImage = SCLAlertViewStyleKit.imageOfCross
            
        case .Notice:
            viewColor = UIColorFromRGB(rgbValue:0x727375)
            iconImage = SCLAlertViewStyleKit.imageOfNotice
            
        case .Warning:
            viewColor = UIColorFromRGB(rgbValue:0xFFD110)
            iconImage = SCLAlertViewStyleKit.imageOfWarning
            
        case .Info:
            viewColor = UIColorFromRGB(rgbValue:0x2866BF)
            iconImage = SCLAlertViewStyleKit.imageOfInfo
            
        case .Edit:
            viewColor = UIColorFromRGB(rgbValue:0xA429FF)
            iconImage = SCLAlertViewStyleKit.imageOfEdit
        }
        
        // Title
        if !title.isEmpty {
            self.labelTitle.text = title
        }
        
        // Subtitle
        if !subTitle.isEmpty {
            viewText.text = subTitle
            // Adjust text view size, if necessary
            let str = subTitle as NSString
//            let attr = [NSFontAttributeName:viewText.font]
            let sz = CGSize(width: kWindowWidth - 24, height:90)
            let r = str.boundingRect(with: sz, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes:[NSFontAttributeName:viewText.font!], context:nil)
            let ht = ceil(r.size.height)
            if ht < kTextHeight {
                kWindowHeight -= (kTextHeight - ht)
                kTextHeight = ht
            }
        }
        
        // Done button
        if ( completeText != nil)
        {
            let txt = completeText!;
            addButton(title: txt, target:self, selector:#selector(SCLAlertView.hideView))
        }
        // Alert view colour and images
        self.circleView.backgroundColor = viewColor
        self.circleIconImageView.image  = iconImage
        for txt in inputs {
            txt.layer.borderColor = viewColor.cgColor
        }
        for btn in buttons {
            btn.backgroundColor = viewColor
            if style == SCLAlertViewStyle.Warning {
                btn.setTitleColor(UIColor.black, for:UIControlState.normal)
            }
        }
        
        // Adding duration
        let doubleValue = duration! as Double
        
        if doubleValue > 0.0 {
            durationTimer?.invalidate()
            durationTimer = Timer.scheduledTimer(timeInterval: duration!, target: self, selector: #selector(SCLAlertView.hideView), userInfo: nil, repeats: false)
        }
        
        // Animate in the alert view
        UIView.animate(withDuration: 0.2, animations: {
            self.view.frame.origin.y = rv.center.y - 100
            self.view.alpha = 1
            }, completion: { finished in
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.center = rv.center
                })
        })
        // Chainable objects
        return SCLAlertViewResponder(alertview: self)
    }
    
    // Close SCLAlertView
    func hideView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 0
            }, completion: { finished in
                self.view.removeFromSuperview()
        })
    }
    
    // Helper function to convert from RGB to UIColor
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

// ------------------------------------
// Icon drawing
// Code generated by PaintCode
// ------------------------------------

class SCLAlertViewStyleKit : NSObject {
    
    // Cache
    struct Cache {
        static var imageOfCheckmark: UIImage?
        static var checkmarkTargets: [AnyObject]?
        static var imageOfCross: UIImage?
        static var crossTargets: [AnyObject]?
        static var imageOfNotice: UIImage?
        static var noticeTargets: [AnyObject]?
        static var imageOfWarning: UIImage?
        static var warningTargets: [AnyObject]?
        static var imageOfInfo: UIImage?
        static var infoTargets: [AnyObject]?
        static var imageOfEdit: UIImage?
        static var editTargets: [AnyObject]?
    }
    
    // Initialization
//    override class func load() {
//    }
    
    // Drawing Methods
    class func drawCheckmark() {
        // Checkmark Shape Drawing
        let checkmarkShapePath = UIBezierPath()
        checkmarkShapePath.move(to: CGPoint(x:73.25, y:14.05))
        checkmarkShapePath.addCurve(to: CGPoint(x:64.51,y: 13.86), controlPoint1: CGPoint(x:70.98, y:11.44), controlPoint2: CGPoint(x:66.78,y: 11.26))
        checkmarkShapePath.addLine(to: CGPoint(x:27.46, y:52))
        checkmarkShapePath.addLine(to: CGPoint(x:15.75, y:39.54))
        checkmarkShapePath.addCurve(to: CGPoint(x:6.84, y:39.54), controlPoint1: CGPoint(x:13.48, y:36.93), controlPoint2: CGPoint(x:9.28, y:36.93))
        checkmarkShapePath.addCurve(to: CGPoint(x:6.84, y:49.02), controlPoint1: CGPoint(x:4.39, y:42.14), controlPoint2: CGPoint(x:4.39, y:46.42))
        checkmarkShapePath.addLine(to: CGPoint(x:22.91, y:66.14))
        checkmarkShapePath.addCurve(to: CGPoint(x:27.28, y:68), controlPoint1: CGPoint(x:24.14, y:67.44), controlPoint2: CGPoint(x:25.71, y:68))
        checkmarkShapePath.addCurve(to: CGPoint(x:31.65, y:66.14), controlPoint1: CGPoint(x:28.86, y:68), controlPoint2: CGPoint(x:30.43, y:67.26))
        checkmarkShapePath.addLine(to: CGPoint(x:73.08, y:23.35))
        checkmarkShapePath.addCurve(to: CGPoint(x:73.25, y:14.05), controlPoint1: CGPoint(x:75.52, y:20.75), controlPoint2: CGPoint(x:75.7, y:16.65))
        checkmarkShapePath.close()
        checkmarkShapePath.miterLimit = 4;
        
        UIColor.white.setFill()
        checkmarkShapePath.fill()
    }
    
    class func drawCross() {
        // Cross Shape Drawing
        let crossShapePath = UIBezierPath()
        crossShapePath.move(to: CGPoint(x:10, y:70))
        crossShapePath.addLine(to: CGPoint(x:70, y:10))
        crossShapePath.move(to: CGPoint(x:10, y:10))
        crossShapePath.addLine(to: CGPoint(x:70, y:70))
        crossShapePath.lineCapStyle = CGLineCap.round;
        crossShapePath.lineJoinStyle = CGLineJoin.round;
        UIColor.white.setStroke()
        crossShapePath.lineWidth = 14
        crossShapePath.stroke()
    }
    
    class func drawNotice() {
        // Notice Shape Drawing
        let noticeShapePath = UIBezierPath()
        noticeShapePath.move(to: CGPoint(x:72, y:48.54))
        noticeShapePath.addLine(to: CGPoint(x:72, y:39.9))
        noticeShapePath.addCurve(to: CGPoint(x:66.38, y:34.01), controlPoint1: CGPoint(x:72, y:36.76), controlPoint2: CGPoint(x:69.48, y:34.01))
        noticeShapePath.addCurve(to: CGPoint(x:61.53, y:35.97), controlPoint1: CGPoint(x:64.82, y:34.01), controlPoint2: CGPoint(x:62.69, y:34.8))
        noticeShapePath.addCurve(to: CGPoint(x:60.36, y:35.78), controlPoint1: CGPoint(x:61.33, y:35.97), controlPoint2: CGPoint(x:62.3, y:35.78))
        noticeShapePath.addLine(to: CGPoint(x:60.36, y:33.22))
        noticeShapePath.addCurve(to: CGPoint(x:54.16, y:26.16), controlPoint1: CGPoint(x:60.36, y:29.3), controlPoint2: CGPoint(x:57.65, y:26.16))
        noticeShapePath.addCurve(to: CGPoint(x:48.73, y:29.89), controlPoint1: CGPoint(x:51.64, y:26.16), controlPoint2: CGPoint(x:50.67, y:27.73))
        noticeShapePath.addLine(to: CGPoint(x:48.73, y:28.71))
        noticeShapePath.addCurve(to: CGPoint(x:43.49, y:21.64), controlPoint1: CGPoint(x:48.73, y:24.78), controlPoint2: CGPoint(x:46.98, y:21.64))
        noticeShapePath.addCurve(to: CGPoint(x:39.03, y:25.37), controlPoint1: CGPoint(x:40.97, y:21.64), controlPoint2: CGPoint(x:39.03, y:23.01))
        noticeShapePath.addLine(to: CGPoint(x:39.03, y:9.07))
        noticeShapePath.addCurve(to: CGPoint(x:32.24,y: 2), controlPoint1: CGPoint(x:39.03, y:5.14), controlPoint2: CGPoint(x:35.73,y: 2))
        noticeShapePath.addCurve(to: CGPoint(x:25.45, y:9.07), controlPoint1: CGPoint(x:28.56,y: 2), controlPoint2: CGPoint(x:25.45, y:5.14))
        noticeShapePath.addLine(to: CGPoint(x:25.45, y:41.47))
        noticeShapePath.addCurve(to: CGPoint(x:24.29, y:43.44), controlPoint1: CGPoint(x:25.45, y:42.45), controlPoint2: CGPoint(x:24.68,y: 43.04))
        noticeShapePath.addCurve(to: CGPoint(x:9.55, y:43.04), controlPoint1: CGPoint(x:16.73,y: 40.88), controlPoint2: CGPoint(x:11.88, y:40.69))
        noticeShapePath.addCurve(to: CGPoint(x:8, y:46.58), controlPoint1: CGPoint(x:8.58, y:43.83), controlPoint2: CGPoint(x:8, y:45.2))
        noticeShapePath.addCurve(to: CGPoint(x:14.4, y:55.81), controlPoint1: CGPoint(x:8.19, y:50.31), controlPoint2: CGPoint(x:12.07, y:53.84))
        noticeShapePath.addLine(to: CGPoint(x:27.2, y:69.56))
        noticeShapePath.addCurve(to: CGPoint(x:42.91, y:77.8), controlPoint1: CGPoint(x:30.5, y:74.47), controlPoint2: CGPoint(x:35.73,y: 77.21))
        noticeShapePath.addCurve(to: CGPoint(x:43.88, y:77.8), controlPoint1: CGPoint(x:43.3, y:77.8), controlPoint2: CGPoint(x:43.68, y:77.8))
        noticeShapePath.addCurve(to: CGPoint(x:47.18, y:78), controlPoint1: CGPoint(x:45.04, y:77.8), controlPoint2: CGPoint(x:46.01,y: 78))
        noticeShapePath.addLine(to: CGPoint(x:48.34, y:78))
        noticeShapePath.addLine(to: CGPoint(x:48.34, y:78))
        noticeShapePath.addCurve(to: CGPoint(x:71.61, y:52.08), controlPoint1: CGPoint(x:56.48, y:78), controlPoint2: CGPoint(x:69.87,y: 75.05))
        noticeShapePath.addCurve(to: CGPoint(x:72, y:48.54), controlPoint1: CGPoint(x:71.81, y:51.29), controlPoint2: CGPoint(x:72, y:49.72))
        noticeShapePath.close()
        noticeShapePath.miterLimit = 4;
        
        UIColor.white.setFill()
        noticeShapePath.fill()
    }
    
    class func drawWarning() {
        // Color Declarations
        let greyColor = UIColor(red: 0.236, green: 0.236, blue: 0.236, alpha: 1.000)
        
        // Warning Group
        // Warning Circle Drawing
        let warningCirclePath = UIBezierPath()
        warningCirclePath.move(to: CGPoint(x:40.94, y:63.39))
        warningCirclePath.addCurve(to: CGPoint(x:36.03, y:65.55), controlPoint1: CGPoint(x:39.06, y:63.39), controlPoint2: CGPoint(x:37.36,y: 64.18))
        warningCirclePath.addCurve(to: CGPoint(x:34.14, y:70.45), controlPoint1: CGPoint(x:34.9,y: 66.92), controlPoint2: CGPoint(x:34.14, y:68.49))
        warningCirclePath.addCurve(to: CGPoint(x:36.22, y:75.54), controlPoint1: CGPoint(x:34.14, y:72.41), controlPoint2: CGPoint(x:34.9, y:74.17))
        warningCirclePath.addCurve(to: CGPoint(x:40.94, y:77.5), controlPoint1: CGPoint(x:37.54, y:76.91), controlPoint2: CGPoint(x:39.06, y:77.5))
        warningCirclePath.addCurve(to: CGPoint(x:45.86, y:75.35), controlPoint1: CGPoint(x:42.83, y:77.5), controlPoint2: CGPoint(x:44.53, y:76.72))
        warningCirclePath.addCurve(to: CGPoint(x:47.93, y:70.45), controlPoint1: CGPoint(x:47.18, y:74.17), controlPoint2: CGPoint(x:47.93,y: 72.41))
        warningCirclePath.addCurve(to: CGPoint(x:45.86, y:65.35), controlPoint1: CGPoint(x:47.93, y:68.49), controlPoint2: CGPoint(x:47.18, y:66.72))
        warningCirclePath.addCurve(to: CGPoint(x:40.94, y:63.39), controlPoint1: CGPoint(x:44.53, y:64.18), controlPoint2: CGPoint(x:42.83, y:63.39))
        warningCirclePath.close()
        warningCirclePath.miterLimit = 4;
        
        greyColor.setFill()
        warningCirclePath.fill()
        
        
        // Warning Shape Drawing
        let warningShapePath = UIBezierPath()
        warningShapePath.move(to: CGPoint(x:46.23, y:4.26))
        warningShapePath.addCurve(to: CGPoint(x:40.94, y:2.5), controlPoint1: CGPoint(x:44.91, y:3.09), controlPoint2: CGPoint(x:43.02,y: 2.5))
        warningShapePath.addCurve(to: CGPoint(x:34.71, y:4.26), controlPoint1: CGPoint(x:38.68, y:2.5), controlPoint2: CGPoint(x:36.03,y: 3.09))
        warningShapePath.addCurve(to: CGPoint(x:31.5, y:8.77), controlPoint1: CGPoint(x:33.01,y: 5.44), controlPoint2: CGPoint(x:31.5, y:7.01))
        warningShapePath.addLine(to: CGPoint(x:31.5,y: 19.36))
        warningShapePath.addLine(to: CGPoint(x:34.71,y: 54.44))
        warningShapePath.addCurve(to: CGPoint(x:40.38, y:58.16), controlPoint1: CGPoint(x:34.9,y: 56.2), controlPoint2: CGPoint(x:36.41, y:58.16))
        warningShapePath.addCurve(to: CGPoint(x:45.67, y:54.44), controlPoint1: CGPoint(x:44.34,y: 58.16), controlPoint2: CGPoint(x:45.67, y:56.01))
        warningShapePath.addLine(to: CGPoint(x:48.5, y:19.36))
        warningShapePath.addLine(to: CGPoint(x:48.5,y: 8.77))
        warningShapePath.addCurve(to: CGPoint(x:46.23, y:4.26), controlPoint1: CGPoint(x:48.5, y:7.01), controlPoint2: CGPoint(x:47.74, y:5.44))
        warningShapePath.close()
        warningShapePath.miterLimit = 4;
        
        greyColor.setFill()
        warningShapePath.fill()
    }
    
    class func drawInfo() {
        // Color Declarations
        let color0 = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        
        // Info Shape Drawing
        let infoShapePath = UIBezierPath()
        infoShapePath.move(to: CGPoint(x:45.66, y:15.96))
        infoShapePath.addCurve(to: CGPoint(x:45.66, y:5.22), controlPoint1: CGPoint(x:48.78, y:12.99), controlPoint2: CGPoint(x:48.78,y: 8.19))
        infoShapePath.addCurve(to: CGPoint(x:34.34, y:5.22), controlPoint1: CGPoint(x:42.53, y:2.26), controlPoint2: CGPoint(x:37.47, y:2.26))
        infoShapePath.addCurve(to: CGPoint(x:34.34, y:15.96), controlPoint1: CGPoint(x:31.22, y:8.19), controlPoint2: CGPoint(x:31.22, y:12.99))
        infoShapePath.addCurve(to: CGPoint(x:45.66, y:15.96), controlPoint1: CGPoint(x:37.47, y:18.92), controlPoint2: CGPoint(x:42.53, y:18.92))
        infoShapePath.close()
        infoShapePath.move(to: CGPoint(x:48, y:69.41))
        infoShapePath.addCurve(to: CGPoint(x:40, y:77), controlPoint1: CGPoint(x:48, y:73.58), controlPoint2: CGPoint(x:44.4,y: 77))
        infoShapePath.addLine(to: CGPoint(x:40, y:77))
        infoShapePath.addCurve(to: CGPoint(x:32, y:69.41), controlPoint1: CGPoint(x:35.6, y:77), controlPoint2: CGPoint(x:32, y:73.58))
        infoShapePath.addLine(to: CGPoint(x:32, y:35.26))
        infoShapePath.addCurve(to: CGPoint(x:40,y: 27.67), controlPoint1: CGPoint(x:32, y:31.08), controlPoint2: CGPoint(x:35.6,y: 27.67))
        infoShapePath.addLine(to: CGPoint(x:40,y: 27.67))
        infoShapePath.addCurve(to: CGPoint(x:48, y:35.26), controlPoint1: CGPoint(x:44.4,y: 27.67), controlPoint2: CGPoint(x:48, y:31.08))
        infoShapePath.addLine(to: CGPoint(x:48,y: 69.41))
        infoShapePath.close()
        color0.setFill()
        infoShapePath.fill()
    }
    
    class func drawEdit() {
        // Color Declarations
        let color = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        
        // Edit shape Drawing
        let editPathPath = UIBezierPath()
        editPathPath.move(to: CGPoint(x:71, y:2.7))
        editPathPath.addCurve(to: CGPoint(x:71.9, y:15.2), controlPoint1: CGPoint(x:74.7, y:5.9), controlPoint2: CGPoint(x:75.1, y:11.6))
        editPathPath.addLine(to: CGPoint(x:64.5, y:23.7))
        editPathPath.addLine(to: CGPoint(x:49.9, y:11.1))
        editPathPath.addLine(to: CGPoint(x:57.3, y:2.6))
        editPathPath.addCurve(to: CGPoint(x:69.7, y:1.7), controlPoint1: CGPoint(x:60.4, y:-1.1), controlPoint2: CGPoint(x:66.1, y:-1.5))
        editPathPath.addLine(to: CGPoint(x:71, y:2.7))
        editPathPath.addLine(to: CGPoint(x:71, y:2.7))
        editPathPath.close()
        editPathPath.move(to: CGPoint(x:47.8, y:13.5))
        editPathPath.addLine(to: CGPoint(x:13.4, y:53.1))
        editPathPath.addLine(to: CGPoint(x:15.7, y:55.1))
        editPathPath.addLine(to: CGPoint(x:50.1, y:15.5))
        editPathPath.addLine(to: CGPoint(x:47.8, y:13.5))
        editPathPath.addLine(to: CGPoint(x:47.8, y:13.5))
        editPathPath.close()
        editPathPath.move(to: CGPoint(x:17.7,y: 56.7))
        editPathPath.addLine(to: CGPoint(x:23.8, y:62.2))
        editPathPath.addLine(to: CGPoint(x:58.2,y: 22.6))
        editPathPath.addLine(to: CGPoint(x:52, y:17.1))
        editPathPath.addLine(to: CGPoint(x:17.7, y:56.7))
        editPathPath.addLine(to: CGPoint(x:17.7, y:56.7))
        editPathPath.close()
        editPathPath.move(to: CGPoint(x:25.8, y:63.8))
        editPathPath.addLine(to: CGPoint(x:60.1, y:24.2))
        editPathPath.addLine(to: CGPoint(x:62.3, y:26.1))
        editPathPath.addLine(to: CGPoint(x:28.1, y:65.7))
        editPathPath.addLine(to: CGPoint(x:25.8, y:63.8))
        editPathPath.addLine(to: CGPoint(x:25.8, y:63.8))
        editPathPath.close()
        editPathPath.move(to: CGPoint(x:25.9, y:68.1))
        editPathPath.addLine(to: CGPoint(x:4.2, y:79.5))
        editPathPath.addLine(to: CGPoint(x:11.3,y: 55.5))
        editPathPath.addLine(to: CGPoint(x:25.9, y:68.1))
        editPathPath.close()
        editPathPath.miterLimit = 4;
        editPathPath.usesEvenOddFillRule = true;
        color.setFill()
        editPathPath.fill()
    }
    
    // Generated Images
    class var imageOfCheckmark: UIImage {
        if (Cache.imageOfCheckmark != nil) {
            return Cache.imageOfCheckmark!
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width:80, height:80), false, 0)
        SCLAlertViewStyleKit.drawCheckmark()
        Cache.imageOfCheckmark = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfCheckmark!
    }
    
    class var imageOfCross: UIImage {
        if (Cache.imageOfCross != nil) {
            return Cache.imageOfCross!
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width:80,height: 80), false, 0)
        SCLAlertViewStyleKit.drawCross()
        Cache.imageOfCross = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfCross!
    }
    
    class var imageOfNotice: UIImage {
        if (Cache.imageOfNotice != nil) {
            return Cache.imageOfNotice!
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width:80, height:80), false, 0)
        SCLAlertViewStyleKit.drawNotice()
        Cache.imageOfNotice = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfNotice!
    }
    
    class var imageOfWarning: UIImage {
        if (Cache.imageOfWarning != nil) {
            return Cache.imageOfWarning!
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width:80, height:80), false, 0)
        SCLAlertViewStyleKit.drawWarning()
        Cache.imageOfWarning = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfWarning!
    }
    
    class var imageOfInfo: UIImage {
        if (Cache.imageOfInfo != nil) {
            return Cache.imageOfInfo!
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width:80, height:80), false, 0)
        SCLAlertViewStyleKit.drawInfo()
        Cache.imageOfInfo = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfInfo!
    }
    
    class var imageOfEdit: UIImage {
        if (Cache.imageOfEdit != nil) {
            return Cache.imageOfEdit!
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width:80, height:80), false, 0)
        SCLAlertViewStyleKit.drawEdit()
        Cache.imageOfEdit = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfEdit!
    }
}
