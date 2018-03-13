//
//  Person.swift
//  GCDTest
//
//  Created by Haitang on 2018/3/12.
//  Copyright © 2018年 Haitang. All rights reserved.
//

import Foundation

class Person: NSObject {
   @objc var name:String?
   @objc static let shared = Person.init()
    private override init(){}
}
