//
//  ViewController.swift
//  premiumAlarm
//
//  Created by Ryo Endo on 2018/07/20.
//  Copyright © 2018年 Ryo Endo. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate, UITextFieldDelegate {

    @IBOutlet weak var alarmWeekDayTextFiled: UITextField!
    var weekDayPickerView = UIPickerView()
    var weekDayArray =  ["月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日", "日曜日"]
    
    @IBOutlet weak var alarmTimeTextField: UITextField!
    var timePickerView = UIPickerView()
    var timeArray = [[00, 01,02,03,04,05,06,07,08,09,10, 11, 12, 13, 14, 15, 16, 17, 18 ,19, 20, 21, 22, 23],
                     [00, 01,02,03,04,05,06,07,08,09,
                      10, 11, 12, 13, 14, 15, 16, 17, 18 ,19,
                      20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
                      30, 31, 32, 33, 34, 35, 36, 37, 38 ,39,
                      40, 41, 42, 43, 44, 45, 46, 47, 48 ,49,
                      50, 51, 52, 53, 54, 55, 56, 57, 58 ,59]]
    
    @IBOutlet weak var nowTimeLabel: UILabel!
    @IBOutlet weak var nowWeekDayLabel: UILabel!
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    var audioPlayer:AVAudioPlayer!
    var goHomeaudioPlayer:AVAudioPlayer!
    var silentAudioPlayer:AVAudioPlayer!
    var date = Date()
    var Counttimer = Timer()                 // Timerクラス
    var startTime: TimeInterval = 0     // Startボタンを押した時刻
    var elapsedTime: Double = 0.0       // Stopボタンを押した時点で経過していた時間
    var time : Double = 0.0
    var isOnSwitch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alarmWeekDayTextFiled.placeholder = "曜日"
        alarmTimeTextField.placeholder = "時刻"
        //無音
        let silentPath = Bundle.main.path(forResource: "silentMusic", ofType:"mp3")!
        let silentUrl = URL(fileURLWithPath: silentPath)
        // auido を再生するプレイヤーを作成する
        var audioError2:NSError?
        do {
            silentAudioPlayer = try AVAudioPlayer(contentsOf: silentUrl)
        } catch let error as NSError {
            audioError2 = error
            silentAudioPlayer = nil
        }
        // エラーが起きたとき
        if let error = audioError2 {
            print("Error \(error.localizedDescription)")
        }
        
        //ゆっくり
        let goHomePath = Bundle.main.path(forResource: "goHome", ofType:"mp3")!
        let goHomeUrl = URL(fileURLWithPath: goHomePath)
        // auido を再生するプレイヤーを作成する
        var audioError1:NSError?
        do {
            goHomeaudioPlayer = try AVAudioPlayer(contentsOf: goHomeUrl)
        } catch let error as NSError {
            audioError1 = error
            goHomeaudioPlayer = nil
        }
        // エラーが起きたとき
        if let error = audioError1 {
            print("Error \(error.localizedDescription)")
        }
        
        // 再生する audio ファイルのパスを取得（蛍の光）
        let audioPath = Bundle.main.path(forResource: "hotarunohikari", ofType:"mp3")!
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
        goHomeaudioPlayer.delegate = self
        goHomeaudioPlayer.prepareToPlay()
        silentAudioPlayer.delegate = self
        silentAudioPlayer.prepareToPlay()
        
        // 1秒ごとに「displayClock」を実行する
        let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(displayClock), userInfo: nil, repeats: true)
        timer.fire()    // 無くても動くけどこれが無いと初回の実行がラグる
        
        // 1秒ごとに「checkdate」を実行する
        let checkTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkDate), userInfo: nil, repeats: true)
        checkTimer.fire()    // 無くても動くけどこれが無いと初回の実行がラグる
        
        if isOnSwitch == true {
            alarmSwitch.isOn = true
        } else {
            alarmSwitch.isOn = false
        }
        
        //曜日を表示
        nowWeekDayLabel.text = date.weekday
        
        settingWeekdayPickerViewFunc()
        settingTimePickerViewFunc()
    }
    
    // 現在時刻を表示する処理
    @objc func displayClock() {
        // 現在時刻を「HH:MM:SS」形式で取得する
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let displayTime = formatter.string(from: Date())    // Date()だけで現在時刻を表す
        // ラベルに表示
        nowTimeLabel.text = displayTime
    }
    
    // 金曜日の19:55かを判断して音を鳴らすか決める
    @objc func checkDate() {
        if isOnSwitch == true {
            if nowWeekDayLabel.text == nowWeekDayLabel.text && nowTimeLabel.text == alarmTimeTextField.text! {
                //ゆっくり
                goHomeaudioPlayer.play()

                //蛍の光-------------------------
                audioPlayer.play()
                //リピート（マイナスにすると無限、プラスならその回数分上乗せ）
                audioPlayer.numberOfLoops = -1
                //タイマーを起動（NCMBに保存するデータ）
                // Startボタンを押した時刻を保存
                startTime = Date().timeIntervalSince1970
                //蛍の光-------------------------
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //アラームのセット
    @IBAction func switchONOFF(_ sender: UISwitch) {
        if sender.isOn == true {
            //無音スタート
            silentAudioPlayer.play()
            silentAudioPlayer.numberOfLoops = -1
            
            isOnSwitch = true
            nowTimeLabel.textColor = .red
            nowWeekDayLabel.textColor = .red
            stopButton.backgroundColor = .red
        } else {
            //無音リセット
            silentAudioPlayer.stop()
            
            isOnSwitch = false
            audioPlayer.currentTime = 0
            nowTimeLabel.textColor = .white
            nowWeekDayLabel.textColor = .white
            stopButton.backgroundColor = .blue
            stopButton.backgroundColor = .blue
            //再生してら曲止める
            if ( audioPlayer.isPlaying ){
                audioPlayer.stop()
                //セーブ
                //self.saveData()
            }
            if ( goHomeaudioPlayer.isPlaying ){
                goHomeaudioPlayer.stop()
            }
        }
        
    }
    
    // ストップボタン
    @IBAction func tappedStopButton(_ sender : AnyObject) {
        if ( audioPlayer.isPlaying ){
            audioPlayer.stop()
            silentAudioPlayer.stop()
            alarmSwitch.isOn = false
            //初めから再生
            audioPlayer.currentTime = 0
            //セーブ
            //self.saveData()
        }

        if ( goHomeaudioPlayer.isPlaying ){
            goHomeaudioPlayer.stop()
        }
    }

}


extension ViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView.tag {
        case 1:
            return 1
        case 2:
            return 2
        default:
            return 1
        }
    }
    
    //表示列
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        switch pickerView.tag {
        case 1:
            return 1
        case 2:
            return 2
        default:
            return 1
        }
    }
    
    //表示個数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return weekDayArray.count
        case 2:
            return timeArray[component].count
        default:
            return 1
        }
    }
    
    //表示内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return weekDayArray[row]
        case 2:
            return String(format: "%02d", timeArray[component][row])
                //String(timeArray[component][row])
        default:
           return "hoge"
        }
    }
    
    //選択時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView.tag {
        case 1:
           alarmWeekDayTextFiled.text = weekDayArray[row]
        case 2:
            //コンポーネントごとに現在選択されているデータを取得する。
            let data1 = self.pickerView(pickerView, titleForRow: pickerView.selectedRow(inComponent: 0), forComponent: 0)
            let data2 = self.pickerView(pickerView, titleForRow: pickerView.selectedRow(inComponent: 1), forComponent: 1)
            alarmTimeTextField.text = data1! + ":" + data2!
        default:
            break
        }
    }
    
    
    func settingWeekdayPickerViewFunc() {
        
        weekDayPickerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: weekDayPickerView.bounds.size.height)
        weekDayPickerView.tag = 1
        weekDayPickerView.delegate   = self
        weekDayPickerView.dataSource = self
        
        let vi1 = UIView(frame: weekDayPickerView.bounds)
        vi1.backgroundColor = UIColor.white
        vi1.addSubview(weekDayPickerView)
        
        alarmWeekDayTextFiled.inputView = vi1
        
        let toolBar1 = UIToolbar()
        toolBar1.barStyle = UIBarStyle.default
        toolBar1.isTranslucent = true
        toolBar1.tintColor = UIColor.black
        let doneButton1   = UIBarButtonItem(title: "選択", style: UIBarButtonItemStyle.done, target: self, action: #selector(ViewController.donePressed))
        let spaceButton1  = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar1.setItems([spaceButton1, doneButton1], animated: false)
        toolBar1.isUserInteractionEnabled = true
        toolBar1.sizeToFit()
        alarmWeekDayTextFiled.inputAccessoryView = toolBar1
    }
    
    func settingTimePickerViewFunc() {
        
        timePickerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: timePickerView.bounds.size.height)
        timePickerView.tag = 2
        timePickerView.delegate   = self
        timePickerView.dataSource = self
        
        let vi2 = UIView(frame: timePickerView.bounds)
        vi2.backgroundColor = UIColor.white
        vi2.addSubview(timePickerView)
        
        alarmTimeTextField.inputView = vi2
        
        let toolBar2 = UIToolbar()
        toolBar2.barStyle = UIBarStyle.default
        toolBar2.isTranslucent = true
        toolBar2.tintColor = UIColor.black
        let doneButton2   = UIBarButtonItem(title: "選択", style: UIBarButtonItemStyle.done, target: self, action: #selector(ViewController.donePressed))
        let spaceButton2  = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar2.setItems([spaceButton2, doneButton2], animated: false)
        toolBar2.isUserInteractionEnabled = true
        toolBar2.sizeToFit()
        alarmTimeTextField.inputAccessoryView = toolBar2
    }
    
    // Done
    @objc func donePressed() {
        view.endEditing(true)
    }
    
    
}
