//
//  AutomatedTestsUITests.swift
//  AutomatedTestsUITests
//
//  Created by Lucas Sousa Silva on 07/07/20.
//  Copyright © 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA. All rights reserved.
//

import Foundation
class CucumberishInitializer: NSObject {
    @objc class func CucumberishSwiftInit()
    {
        var application : XCUIApplication!
        //A closure that will be executed only before executing any of your features
        beforeStart { () -> Void in
            ButtonScreenSteps().ButtonScreenSteps()
            TabViewScreenSteps().TabViewScreenSteps()
            ImageScreenSteps().ImageScreenSteps()
        }
        
        //A Given step definitiona
        Given("the app will load (.*)$") { (args, userInfo) -> Void in
            let url = args?[0] ?? ""
            
            
            application = XCUIApplication()
            application.launchEnvironment["InitialUrl"] = url
            application.launch()
    
        }

        
        let bundle = Bundle(for: CucumberishInitializer.self)

        Cucumberish.executeFeatures(inDirectory: "Features", from: bundle, includeTags: nil, excludeTags: nil)
    }
    
    class func waitForElementToAppear(_ element: XCUIElement) {
        let result = element.waitForExistence(timeout: 10)
        guard result else {
            XCTFail("Element does not appear")
            return
        }
    }

    fileprivate class func getTags() -> [String]? {
        var itemsTags: [String]?
        for i in ProcessInfo.processInfo.arguments {
            if i.hasPrefix("-Tags:") {
                let newItems = i.replacingOccurrences(of: "-Tags:", with: "")
                itemsTags = newItems.components(separatedBy: ",")
            }
        }
        return itemsTags
    }
    
}