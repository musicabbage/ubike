//
//  UBikeModel.swift
//  ubike
//
//  Created by cabbage on 2020/9/22.
//  Copyright © 2020 cabbage. All rights reserved.
//

import Foundation
import CoreLocation

struct Result<T: Decodable>: Decodable {
    let code: Int
    let value: T
    
    private enum Keys: String, CodingKey {
        case code = "retCode"
        case value = "retVal"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        code = try container.decode(Int.self, forKey: .code)
        value = try container.decode(T.self, forKey: .value)
    }
}

struct Stop: Decodable {
    /**
     "sno": "0404",
     "sna": "民族延平路口",
     "tot": "30",
     "sbi": "2",
     "sarea": "大同區",
     "mday": "20200922091148",
     "lat": "25.068653",
     "lng": "121.510569",
     "ar": "民族西路 310 號前方",
     "sareaen": "Datong Dist.",
     "snaen": "Minzu & Yanping Intersection",
     "aren": "No.310, Minzu W. Rd.",
     "bemp": "28",
     "act": "1"
     */
    let sno: String!    //站點代號
    let sna: String!    //中文場站名稱
    let tot: Int!       //場站總停車格
    let sbi: Int!       //可借車位數
    let sarea: String!  //中文場站區域
    let mday: Date?     //資料更新時間
//    let lat": "25.0330388889",
//    let lng": "121.565619444",
    let coordinate: CLLocationCoordinate2D?
    let ar: String!     //中文地址
    let sareaen: String!    //英文場站區域
    let snaen: String!  //英文場站名稱
    let aren: String!   //英文地址
    let bemp: Int!      //可還空位數
    let act: Int!       //場站是否暫停營運
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMDDHHMMSS" //20200922091131
        return dateFormatter
    }()
    
    private enum Keys: CodingKey {
        case sno, sna, tot, sbi, sarea, mday, ar, sareaen, snaen, aren, bemp, act
        case lat, lng
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        sno = try container.decode(String.self, forKey: .sno)
        sna = try container.decode(String.self, forKey: .sna)
        if let value = try Int(container.decode(String.self, forKey: .tot)) {
            tot = value
        } else {
            tot = 0
        }
        if let value = try Int(container.decode(String.self, forKey: .sbi)) {
            sbi = value
        } else {
            sbi = 0
        }
        
        sarea = try container.decode(String.self, forKey: .sarea)
        if let dayString = try container.decode(String.self, forKey: .mday) as String?,
            let date = Stop.dateFormatter.date(from: dayString) {
            mday = date
        } else {
            mday = nil
        }
        if let lat = try Double(container.decode(String.self, forKey: .lat)),
            let lng = try Double(container.decode(String.self, forKey: .lng)) {
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        } else {
            coordinate = nil
        }
        ar = try container.decode(String.self, forKey: .ar)
        sareaen = try container.decode(String.self, forKey: .sareaen)
        snaen = try container.decode(String.self, forKey: .snaen)
        aren = try container.decode(String.self, forKey: .sarea)
        if let value = try Int(container.decode(String.self, forKey: .bemp)) {
            bemp = value
        } else {
            bemp = 0
        }
        
        if let value = try Int(container.decode(String.self, forKey: .act)) {
            act = value
        } else {
            act = 0
        }
    }
}
