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
    @IBOutlet weak var alarmHHTextFiled: UITextField!
    @IBOutlet weak var alarmMMTextField: UITextField!
    @IBOutlet weak var nowTimeLabel: UILabel!
    @IBOutlet weak var nowWeekDayLabel: UILabel!
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
     var timePickerView = UIPickerView()
    
    var weekDayArray =  ["月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日", "日曜日"]
    var audioPlayer:AVAudioPlayer!
    var goHomeaudioPlayer:AVAudioPlayer!
    var date = Date()
    var Counttimer = Timer()                 // Timerクラス
    var startTime: TimeInterval = 0     // Startボタンを押した時刻
    var elapsedTime: Double = 0.0       // Stopボタンを押した時点で経過していた時間
    var time : Double = 0.0
    var isOnSwitch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        settingPickerViewFunc()
        closeTextField()
    }
    
    
    
    func closeTextField() {
        let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        kbToolBar.barStyle = UIBarStyle.default  // スタイルを設定
        kbToolBar.sizeToFit()  // 画面幅に合わせてサイズを変更
        // スペーサー
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        // 閉じるボタン
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.commitButtonTapped))
        kbToolBar.items = [spacer, commitButton]
        alarmHHTextFiled.inputAccessoryView = kbToolBar
        alarmMMTextField.inputAccessoryView = kbToolBar
    }
    
    @objc func commitButtonTapped() {
        self.view.endEditing(true)
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
            if nowWeekDayLabel.text == nowWeekDayLabel.text && nowTimeLabel.text == alarmHHTextFiled.text! + ":" + alarmMMTextField.text! {
    
                //ゆっくり
                goHomeaudioPlayer.play()
                goHomeaudioPlayer.numberOfLoops = 4

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
    
    //textFieldを閉じるコードを書く
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //アラームのセット
    @IBAction func switchONOFF(_ sender: UISwitch) {
        if sender.isOn == true {
            isOnSwitch = true
            nowTimeLabel.textColor = .red
            nowWeekDayLabel.textColor = .red
            stopButton.backgroundColor = .red
        } else {
            isOnSwitch = false
            audioPlayer.currentTime = 0
            nowTimeLabel.textColor = .black
            nowWeekDayLabel.textColor = .black
            stopButton.backgroundColor = .blue
            stopButton.backgroundColor = .blue
            //再生してら曲止める
            if ( audioPlayer.isPlaying ){
                audioPlayer.stop()
                //セーブ
                //self.saveData()
            }
        }
        
    }
    
    // ストップボタン
    @IBAction func tappedStopButton(_ sender : AnyObject) {
        if ( audioPlayer.isPlaying ){
            audioPlayer.stop()
            alarmSwitch.isOn = false
            //初めから再生
            audioPlayer.currentTime = 0
            //セーブ
            //self.saveData()
        }
    }

    
}






extension ViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //表示列
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //表示個数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return weekDayArray.count
    }
    
    //表示内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return weekDayArray[row]
    }
    
    //選択時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        alarmWeekDayTextFiled.text = weekDayArray[row]
    }
    
    func settingPickerViewFunc() {
        
        timePickerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: timePickerView.bounds.size.height)
        timePickerView.tag = 1
        timePickerView.delegate   = self
        timePickerView.dataSource = self
        
        let vi1 = UIView(frame: timePickerView.bounds)
        vi1.backgroundColor = UIColor.white
        vi1.addSubview(timePickerView)
        
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
    
    // Done
    @objc func donePressed() {
        view.endEditing(true)
        
    }
}
