//
//  Dependency.swift
//  App
//
//  Created by Patrick Täufer on 12.04.18.
//  Copyright © 2018 Savedroid AG. All rights reserved.
//

import Foundation

@objcMembers
open class DependencyModule : NSObject {
    
}

open class Dependency {
    public static func inject<T>() -> T {
        return Dependency.inject(String(describing : T.self))
    }
    
    public static func inject<T>(_ c : AnyClass) -> T {
        return Dependency.inject(String(describing : c))
    }
    
    static func inject<T>(_ name : String) -> T {
        if let dep : Array<String> =  ResourcePool.dependencies[name] {
            switch dep[2] {
            case "singleton":
                if let o = (ResourcePool.value(forKey: dep[0].lowercased() + "_module") as? DependencyModule)?.value(forKey: dep[1]) as? T {
                    return o
                }
            default:
                if let o = (ResourcePool.value(forKey: dep[0].lowercased() + "_module") as? DependencyModule)?.perform(NSSelectorFromString(dep[1])).takeUnretainedValue() as? T {
                    return o
                }
            }
        }
        fatalError("dependency for \(name).self not found")
    }
}

