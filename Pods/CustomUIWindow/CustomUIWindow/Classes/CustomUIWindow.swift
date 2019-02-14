//
//  CustomUIWindow.swift
//  CustomUIWindow
//
//  Created by Yang Zhang on 2/10/19.
//

import UIKit

public class CustomUIWindow: UIWindow {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        print("CGPoint: " + String(point.x.description) + ", " + String(point.y.description))
        let view = super.hitTest(point, with: event)
        // print(view?.frame ?? "")
        // 2
        let delimiter = ":"
        let newstr = view?.gestureRecognizers?.first?.description ?? ""
        var token = newstr.components(separatedBy: delimiter)
        print(token[0])
        return view
    }
}

public protocol SwizzlingInjection: class {
    static func inject()
}

public class SwizzlingHelper {

    private static let doOnce: Any? = {
        UIViewController.inject()
        return nil
    }()

    static func enableInjection() {
        _ = SwizzlingHelper.doOnce
    }
}

extension UIApplication {

    override open var next: UIResponder? {
        // Called before applicationDidFinishLaunching
        SwizzlingHelper.enableInjection()
        return super.next
    }

}

public let swizzling: (UIViewController.Type) -> () = { viewController in

    let originalSelector = #selector(viewController.viewWillAppear(_:))
    let swizzledSelector = #selector(viewController.proj_viewWillAppear(animated:))

    let originalMethod = class_getInstanceMethod(viewController, originalSelector)
    let swizzledMethod = class_getInstanceMethod(viewController, swizzledSelector)

    if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

}

extension UIViewController: SwizzlingInjection {

    //    open override class func initialize() {
    //        // make sure this isn't a subclass
    //        guard self === UIViewController.self else { return }
    //        swizzling(self)
    //    }

    public static func inject() {
        // make sure this isn't a subclass
        guard self === UIViewController.self else { return }
        swizzling(self)
    }

    // MARK: - Method Swizzling

    @objc func proj_viewWillAppear(animated: Bool) {
        self.proj_viewWillAppear(animated: animated)

        let viewControllerName = NSStringFromClass(type(of: self))
        print("viewWillAppear: \(viewControllerName)")
    }
}
