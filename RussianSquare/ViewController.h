//
//  ViewController.h
//  RussianSquare
//
//  Created by 蒋尚秀 on 15/11/23.
//  Copyright © 2015年 蒋尚秀. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Block.h"
#import "Board.h"
#import "IType.h"
#import "SType.h"
#import "ZType.h"
#import "LType.h"
#import "JType.h"
#import "OType.h"
#import "TType.h"
#import <AVFoundation/AVFoundation.h>


@interface ViewController : UIViewController<UITextFieldDelegate>
{
    
    NSInteger _score;
    NSInteger _topScore;
    NSInteger _level;
    NSInteger _rows;
    Block * _liveBlock;
    NSMutableArray * _liveImageArray;
    Block * _nextBlock;
    NSMutableArray * _nextImageArray;
    
    UIImageView * _boardImageView;
    Board * _board;
    NSMutableArray * _boardArray;
    
    UIImageView * _backgroundView;
    
    NSTimer * _timer;
    
    //起始、暂停界面
    UIImageView * _startView;
    //游戏结束页面
    UIImageView * _gameoverView;
    //留名页面
    UIImageView * _nameView;
    //上榜页面
    UIImageView * _rankView;
    //排行榜页面Label数组
    NSMutableArray * _rankLabelArray;
    
    NSTimer * _pressTimer;//button长按计时器
    
    AVAudioPlayer * _avPlayer;
    
    NSTimer * _flashTimer;
    
    NSMutableArray * _userInfoArray;
    
    //数据统计
    //消行次数
    NSInteger _oneCount;
    NSInteger _twoCount;
    NSInteger _threeCount;
    NSInteger _fourCount;
    //连击次数
    NSInteger _comboCount;
    NSInteger _time;
    //连击动画页面
    UIImageView * _comboBGView;
    UIImageView * _comboCountView;
    
    //数据统计页面
    UIImageView * _numbersView;
    NSMutableArray * _labelsArray;
    
    //游戏存档页面
    //显示存档页
    UIImageView * _loadFilesView;
    //存储游戏名称页面
    UIImageView * _saveGameView;
    //游戏存储名称text
    UITextField * _gameNameField;
    //游戏存档数据
    NSMutableArray * _allGameArray;
}

-(void)stopBtnClicked:(UIButton *)sender;

-(void)newBlocks;

@end

