//
//  Acc.swift
//  aaa
//
//  Created by Masashi Takata on 2017/12/20.
//  Copyright © 2017年 Masashi Takata. All rights reserved.
//

import Foundation
import RealmSwift

class sensor: Object{
    @objc dynamic var data:String = ""
    @objc dynamic var UserAcc_x:Double = 0
    @objc dynamic var UserAcc_y:Double = 0
    @objc dynamic var UserAcc_z:Double = 0
    @objc dynamic var Gyro_x:Double = 0
    @objc dynamic var Gyro_y:Double = 0
    @objc dynamic var Gyro_z:Double = 0
    @objc dynamic var Gravity_x:Double = 0
    @objc dynamic var Gravity_y:Double = 0
    @objc dynamic var Gravity_z:Double = 0
    @objc dynamic var Acc_x:Double = 0
    @objc dynamic var Acc_y:Double = 0
    @objc dynamic var Acc_z:Double = 0
}

class sensor1: Object{
    @objc dynamic var data:String = ""
    @objc dynamic var Pressure:Double = 0
    @objc dynamic var Altitude:Double = 0
}



