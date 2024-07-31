//
//  Country.swift
//  StreamVPN
//
//  Created by Rootways on 12/02/22.
//

import UIKit

class ModelCountry: NSObject, NSCoding {

    var flag:String  = ""
    var ip:String! = ""
    var isConnected:String! = ""
    var isFree:String! = ""
    var name:String! = ""
    var ps:String! = ""
    var un:String! = ""
    
    init(flag:String!,ip:String!,isConnected:String!,isFree:String!,name:String!,ps:String!,un:String!){
        self.flag = flag
        self.ip = ip
        self.isConnected = isConnected
        self.isFree = isFree
        self.name = name
        self.ps = ps
        self.un = un
    }
    
    required convenience init(coder aDecoder: NSCoder) {
            let flag = aDecoder.decodeObject(forKey: "flag") as! String
            let ip = aDecoder.decodeObject(forKey: "ip") as! String
            let isConnected = aDecoder.decodeObject(forKey: "isConnected") as! String
            let isFree = aDecoder.decodeObject(forKey: "isFree") as! String
            let name = aDecoder.decodeObject(forKey: "name") as! String
            let ps = aDecoder.decodeObject(forKey: "ps") as! String
            let un = aDecoder.decodeObject(forKey: "un") as! String
            self.init(flag: flag, ip: ip, isConnected: isConnected,isFree:isFree,name:name,ps:ps,un:un)
        }

        func encode(with aCoder: NSCoder) {
            aCoder.encode(flag, forKey: "flag")
            aCoder.encode(ip, forKey: "ip")
            aCoder.encode(isConnected, forKey: "isConnected")
            aCoder.encode(isFree, forKey: "isFree")
            aCoder.encode(name, forKey: "name")
            aCoder.encode(ps, forKey: "ps")
            aCoder.encode(un, forKey: "un")
        }
}
