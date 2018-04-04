//
//  ViewController.swift
//  aaa
//
//  Created by Masashi Takata on 2017/12/20.
//  Copyright © 2017年 Masashi Takata. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation
import CoreMotion

class ViewController: UIViewController,AVAudioPlayerDelegate,UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    let systemSoundID: SystemSoundID = 1052
    var audioPlayer:AVAudioPlayer!
    
    // 選択肢
    var dataList = ["10","20","30","40","50","60","70","80","90","100"]
    
    @IBOutlet weak var startRecord: UIButton!
    @IBOutlet weak var shiversText: UILabel!
    @IBOutlet weak var timeSet: UIPickerView!
    
    
    
    
    
    @IBAction func startRecord(_ sender: Any) {
    
        if ( audioPlayer.isPlaying ){
            audioPlayer.stop()
            startRecord.setTitle("Stop", for: UIControlState())
        }
        else{
            audioPlayer.play()
            startRecord.setTitle("Start Record", for: UIControlState())
        }

        //マイグレーション
        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 2) {
                }
        })
        Realm.Configuration.defaultConfiguration = config

        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        
        delay(10){
            self.startLoggingData()
            self.altimeter.stopRelativeAltitudeUpdates()  //高さリセット
            self.self.atmosphericPressure()

        }

        delay(Double((timeSet.selectedRow(inComponent: 0)+1)*10+10)){
            self.stopUpdates()
            AudioServicesPlaySystemSound(self.systemSoundID)
        }
        
    }
    
    @IBAction func stopRecord(_ sender: Any) {
        stopUpdates()
        AudioServicesPlaySystemSound(self.systemSoundID)
    }
    
    @IBAction func shiverButton(_ sender: Any) {
        // デフォルトRealmを取得
        let realm = try! Realm()
        let accs = realm.objects(sensor.self)
        let x = accs.map{ $0.Acc_x}
        print(varp([Double](x)))
        let y = accs.map{ $0.Acc_y}
        print(varp([Double](y)))
        let z = accs.map{ $0.Acc_z}
        print(varp([Double](z)))
        let shivers = varp([Double](x))+varp([Double](y))+varp([Double](z))
        print(shivers)
        shiversText.text = String(format: "プルプル度は %.2f)", shivers)
    }
    
    
    
    // 慣性データを取得するためのクラス
    let motionManager = CMMotionManager()
    // 気圧を取得するためのクラス
    let altimeter = CMAltimeter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 再生する audio ファイルのパスを取得
        let audioPath = Bundle.main.path(forResource: "Countdown", ofType:"mp3")!
        let audioUrl = URL(fileURLWithPath: audioPath)
        
        
        // auido を再生するプレイヤーを作成する
        var audioError:NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
        } catch let error as NSError {
            audioError = error
            audioPlayer = nil
        }
        
        // エラーが起きたとき
        if let error = audioError {
            print("Error \(error.localizedDescription)")
        }
        
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        
        //マイグレーション
        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 2) {
                }
        })
        Realm.Configuration.defaultConfiguration = config
        
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        
        // Delegate設定
        timeSet.delegate = self
        timeSet.dataSource = self
        
        
        
    }
    
    
    func startLoggingData(){
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1/50
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
                // 取得した値をコンソールに表示
                print("x: \(String(describing: data?.rotationRate.x)) y: \(String(describing: data?.rotationRate.y)) z: \(String(describing: data?.rotationRate.z))")
                
                let motion = sensor()
                motion.UserAcc_x = (data?.userAcceleration.x)!
                motion.UserAcc_y = (data?.userAcceleration.y)!
                motion.UserAcc_z = (data?.userAcceleration.z)!
                motion.Gyro_x = (data?.rotationRate.x)!
                motion.Gyro_y = (data?.rotationRate.y)!
                motion.Gyro_z = (data?.rotationRate.z)!
                motion.Gravity_x = (data?.gravity.x)!
                motion.Gravity_y = (data?.gravity.y)!
                motion.Gravity_z = (data?.gravity.z)!
                motion.Acc_x = motion.UserAcc_x + motion.Gravity_x
                motion.Acc_y = motion.UserAcc_y + motion.Gravity_y
                motion.Acc_z = motion.UserAcc_z + motion.Gravity_z
                
                
                let dateFormater = DateFormatter()
                dateFormater.locale = Locale(identifier: "ja_JP")
                dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
                let date = dateFormater.string(from: Date())
                
                motion.data = date
                let realm = try! Realm()
                try! realm.write {
                    realm.add(motion)
                }
                
        })
        
    }
    }
    
    //気圧センサと高度を取得する関数
    func atmosphericPressure(){
        if (CMAltimeter.isRelativeAltitudeAvailable()) {
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main, withHandler:
                {data, error in
                    if error == nil {
                        let pressure:Double = Double(truncating: data!.pressure) * 10 //hPa
                        let altitude:Double = Double(truncating: data!.relativeAltitude)  //m
                        let motion = sensor1()
                        motion.Pressure = pressure
                        motion.Altitude = altitude
                        
                        let dateFormater = DateFormatter()
                        dateFormater.locale = Locale(identifier: "ja_JP")
                        dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
                        let date = dateFormater.string(from: Date())
                        
                        motion.data = date
                        let realm1 = try! Realm()
                        try! realm1.write {
                            realm1.add(motion)
                        }
                    }
            })
        }
    }
    
    
    //開始を遅らせる
    func delay(_ delay:Double, closure:@escaping ()->()){
        //function from stack overflow. Delay in seconds
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
        
    }
    
    func stopUpdates(){
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        motionManager.stopDeviceMotionUpdates()
    }
    
    // 和
    func sum(_ X: [Double]) -> Double {
        var sum = 0.0
        for x in X {
            sum += x
        }
        return sum
    }
    
    // 平均
    func mean(_ X: [Double]) -> Double {
        return sum(X) / Double(X.count)
    }
    
    // 平方和
    func sumOfSquares(_ X: [Double]) -> Double {
        let mu = mean(X)
        var ss = 0.0
        for x in X {
            let deviation = x - mu
            ss += deviation * deviation
        }
        return ss
    }
    
    func varp(_ X: [Double]) -> Double {
        return sumOfSquares(X) / Double(X.count)
    }
    
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ timeSet: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    
    //表示する文字列を指定する
    //PickerViewに表示する配列の要素数を設定する
    func pickerView(_ timeSet: UIPickerView, titleForRow row: Int, forComponent component: Int)-> String? {
        return dataList[row]
    }
    
    //ラベル表示
    func pickerView(_ timeSet: UIPickerView, didSelectRow row: Int, inComponent component: Int){
//        print((timeSet.selectedRow(inComponent: 0)+1)*10+10)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}



