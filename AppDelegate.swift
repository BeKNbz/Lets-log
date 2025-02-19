//
//  AppDelegate.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/05.
//

import UIKit
import CoreData
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        setupNavigationBarAppearance()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        dump(url)
        if url.scheme == "letslog" {
            if let fontViewController = UIViewController.frontViewController(),
                let importFile = UIStoryboard(name: StoryboardName.importFile.rawValue, bundle: nil).instantiateInitialViewController() as? ImportFileViewController {
                importFile.setup(url: url)
                fontViewController.present(importFile, animated: true)
            }
        }
        return true
    }
    
    private func setupNavigationBarAppearance() {
        if #available(iOS 15.0, *) {
            // disable UINavigation bar transparent
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
            let appearance = UINavigationBar.appearance()
            appearance.standardAppearance = navigationBarAppearance
            appearance.compactAppearance = navigationBarAppearance
            appearance.scrollEdgeAppearance = navigationBarAppearance
        }
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        if #available(iOS 13.0, *) {
            let container = NSPersistentCloudKitContainer(name: "LifeLogApp")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }
        let container = NSPersistentContainer(name: "LifeLogApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

}

