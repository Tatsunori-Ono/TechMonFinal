//
//  BattleViewController.swift
//  TechMon
//
//  Created by Tatsunori Ono on 2015/11/29.
//  Copyright © 2015年 Tatsunori Ono. All rights reserved.
//

import UIKit

class BattleViewController: UIViewController {
    
    var moveValueUpTimer: NSTimer!
    
    var enemy: Enemy = Enemy(name:"ドラゴン",imageName: "monster.png")
    var player: Player =  Player(name:"勇者",imageName:"yusya.png")
    let util: TechDraUtility = TechDraUtility()
    
    var isPlayerMoveValueMax: Bool! = true
    
    @IBOutlet var backgroundImageView: UIImageView!
    
    @IBOutlet var attackBotton: UIButton!
    @IBOutlet var fireButton: UIButton!
    @IBOutlet var tameruButton: UIButton!
    
    @IBOutlet var enemyImageView: UIImageView!
    @IBOutlet var playerImageView: UIImageView!
    
    @IBOutlet var enemyHPBar: UIProgressView!
    @IBOutlet var playerHPBar: UIProgressView!
    @IBOutlet var playerMoveBar: UIProgressView!
    @IBOutlet var enemyMoveBar:UIProgressView!
    @IBOutlet var playerTPBar: UIProgressView!
    
    @IBOutlet var enemyNameLabel: UILabel!
    @IBOutlet var playerNamelabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
// Do any additional setup after loading the view.
        initStatus()
        
        moveValueUpTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "moveValueUp", userInfo: nil, repeats: true)
        moveValueUpTimer.fire()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initStatus() {
        
        enemyNameLabel.text = enemy.name
        playerNamelabel.text = player.name
        
        enemyImageView.image = enemy.image
        playerImageView.image = player.image
        
        enemyHPBar.transform = CGAffineTransformMakeScale(1.0,4.0)
        playerHPBar.transform = CGAffineTransformMakeScale(1.0,4.0)
        playerTPBar.transform = CGAffineTransformMakeScale(1.0,4.0)
        
        enemyHPBar.progress = enemy.currentHP / enemy.maxHP
        playerHPBar.progress = player.currentHP / player.maxHP
        playerTPBar.progress = player.currentTP / player.maxTP
    }
    
    override func viewDidAppear(animated: Bool) {
        util.playBGM("BGM_battle001")
    }
    
    func moveValueUp() {
        
        player.currentMovePoint = player.currentMovePoint+1
        playerMoveBar.progress = player.currentMovePoint / player.maxMovePoint
        
        if player.currentMovePoint >= player.maxMovePoint {
            isPlayerMoveValueMax = true
            player.currentMovePoint = player.maxMovePoint
        }else{
            isPlayerMoveValueMax = false
        }
        
        enemy.currentMovePoint = enemy.currentMovePoint+1
        enemyMoveBar.progress = enemy.currentMovePoint / enemy.maxMovePoint
        
        if enemy.currentMovePoint >= enemy.maxMovePoint {
            self.enemyAttack()
            enemy.currentMovePoint = 0
        }
        
    }
    
    func enemyAttack() {
        
        TechDraUtility.damageAnimation(playerImageView)
        util.playSE("SE_attack")
        
        player.currentHP = player.currentHP - enemy.attackPoint
        playerHPBar.setProgress(player.currentHP / player.maxHP, animated: true)
        
        if player.currentHP <= 0.0 {
            finishBattle(playerImageView, winPlayer: false)
        }
    }

    @IBAction func attackAction() {
        
        if isPlayerMoveValueMax == true {
            TechDraUtility.damageAnimation(enemyImageView)
            util.playSE("SE_attack")
            
            enemy.currentHP = enemy.currentHP - player.attackPoint
            enemyHPBar.setProgress(enemy.currentHP / enemy.maxHP, animated: true)
            
            player.currentTP = player.currentTP + 10
            if player.currentTP >= player.maxTP {
                player.currentTP = player.maxTP
            }
            playerTPBar.progress = player.currentTP / player.maxTP
            
            player.currentMovePoint = 0
            
            if enemy.currentHP <= 0.0 {
                finishBattle(enemyImageView, winPlayer: true)
            }
        }
    }
    
    @IBAction func fireAction() {
        if isPlayerMoveValueMax == true && player.currentTP >= 40 {
            
            TechDraUtility.damageAnimation(enemyImageView)
            util.playSE("SE_fire")
            
            enemy.currentHP = enemy.currentHP - 100
            enemyHPBar.setProgress(enemy.currentHP / enemy.maxHP, animated: true)
            
            player.currentTP = player.currentTP - 40
            if player.currentTP <= 0 {
                player.currentTP = 0
                }
            playerTPBar.progress = player.currentTP / player.maxTP
            player.currentMovePoint = 0
            if enemy.currentHP <= 0.0 {
                finishBattle(enemyImageView, winPlayer: true)
            }
        }
    }
    
    @IBAction func tameruAction() {
        if isPlayerMoveValueMax == true && player.currentTP >= 20{
            
            player.attackPoint = player.attackPoint + 30
            util.playSE("SE_charge")
            
            player.currentTP = player.currentTP - 20
            if player.currentTP <= 0 {
                player.currentTP = 0
                }
            playerTPBar.progress = player.currentTP / player.maxTP
            player.currentMovePoint=0
        }
    }
    
    func finishBattle(vanishImageView: UIImageView,winPlayer: Bool){
        TechDraUtility.vanishAnimation(vanishImageView)
        util.stopBGM()
        moveValueUpTimer.invalidate()
        isPlayerMoveValueMax = false
        
        let finishedMessage: String
        
        if attackBotton.hidden != true {
            attackBotton.hidden = true
        }
        if fireButton.hidden != true {
            fireButton.hidden = true
        }
        if tameruButton.hidden != true{
            tameruButton.hidden = true
        }
        
        if winPlayer == true {
            util.playSE("SE_fanfare")
            finishedMessage = "プレイヤーの勝利！！"
        }else {
            util.playSE("SE_gameover")
            finishedMessage = "プレイヤー敗北…"
        }
        let alert = UIAlertController(title:"バトル終了！", message:  finishedMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title:"OK", style: .Default, handler: { action in self.dismissViewControllerAnimated(true, completion: nil)}))
        self.presentViewController(alert, animated: true, completion: nil)
        
        }
    }
    
    
    
    
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

