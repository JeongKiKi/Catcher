//
//  AppDelegate.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/12.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    /**
     @brief  navigationBarController 객체
     */
    var navigationController : UINavigationController?
    
    /**
     @brief  tabBarController 객체
     */
    var tabBarController : BaseTabBarController?
    
    /**
     @enum StartType
     
     @brief  화면시작 지점 구분 enum
     */
    enum StartType : String {
        case Main
    }
    
    let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let introVC = IntroViewController.init(nibName: "IntroViewController", bundle: nil);
        navigationController = UINavigationController.init(rootViewController: introVC);
        //네비게이션바 히든
        navigationController?.isNavigationBarHidden = true;
        window = UIWindow.init(frame: UIScreen.main.bounds);
        window?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1);
        window?.rootViewController = navigationController;
        window?.makeKeyAndVisible();
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    /**
     @brief navigationController의 쌓여있는 스택을 리턴
     */
    static func navigationViewControllers() -> [UIViewController]{
        return AppDelegate.applicationDelegate().navigationController!.viewControllers
    }
    /**
     @brief Appdelegate의 객체를 리턴
     */
    static var realDelegate: AppDelegate?;
    static func applicationDelegate() -> AppDelegate{
        if Thread.isMainThread{
            return UIApplication.shared.delegate as! AppDelegate;
        }
        let dg = DispatchGroup()
        dg.enter()
        DispatchQueue.main.async{
            realDelegate = UIApplication.shared.delegate as? AppDelegate;
            dg.leave();
        }
        dg.wait();
        return realDelegate!
    }
    
    /**
     @brief 최상위ViewController의 객체를 리턴
     */
    static func applicationTopViewController() -> UIViewController? {
        return UIApplication.topViewController()
    }
    
    /**
     @brief storyBoard를 변경한다.
     */
    func changeInitViewController(type : StartType) {
        DataManager.sharedInstance.modalViewControllerList = nil
        tabBarController = nil
        let storyBoard = UIStoryboard(name: type.rawValue, bundle: nil)
        self.navigationController = nil
        self.tabBarController = nil
        let navigationController : UINavigationController?
        navigationController =  storyBoard.instantiateInitialViewController() as? UINavigationController
        if  navigationController?.topViewController is UITabBarController {
            tabBarController = navigationController!.topViewController as? BaseTabBarController
        }
        self.navigationController = navigationController
        
        //네비게이션바 히든
        navigationController?.isNavigationBarHidden = true;
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            AppDelegate.applicationDelegate().window?.rootViewController?.view.alpha = 0
        }) {[weak self] (finished) in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.window?.rootViewController = strongSelf.navigationController
                strongSelf.window?.rootViewController?.view.alpha = 0
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                    AppDelegate.applicationDelegate().window?.rootViewController?.view.alpha = 1
                }, completion: { (finished) in
                })
            }
        }
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = AppDelegate.realDelegate?.keyWindow?.rootViewController ) -> UIViewController? {
            if let navigationController = controller as? UINavigationController {
                return topViewController(controller: navigationController.visibleViewController)
            }
            if let tabController = controller as? UITabBarController {
                if let selected = tabController.selectedViewController {
                    return topViewController(controller: selected)
                }
            }
            if let presented = controller?.presentedViewController {
                return topViewController(controller: presented)
            }
            return controller
        }
}
