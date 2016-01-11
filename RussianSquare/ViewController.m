//
//  ViewController.m
//  RussianSquare
//
//  Created by 蒋尚秀 on 15/11/23.
//  Copyright © 2015年 蒋尚秀. All rights reserved.
//

#import "ViewController.h"
#import "UMSocial.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController ()
{
    //主界面
    UILabel * _topLabel;//最高得分
    UILabel * _levelLabel;//等级
    UILabel * _scoreLabel;//得分
    UILabel * _rowLabel;//行数
    UITextField * _nameText;
    UISwitch * _musicSwitch;//背景音乐开关
    UISwitch * _soundSwitch;//音效开关
    
    UIButton * _leftBtn;
    UIButton * _rightBtn;
    UIButton * _downBtn;
    
    
    
    //数据统计页面
    UILabel * _num_levelLabel;
    UILabel * _num_scoreLabel;
    UILabel * _num_rowLabel;
    UILabel * _num_oneLabel;
    UILabel * _num_twoLabel;
    UILabel * _num_threeLabel;
    UILabel * _num_fourLabel;
    UILabel * _num_comboLabel;
}

@end


#define VIEW_W self.view.frame.size.width
#define VIEW_H self.view.frame.size.height

#define ROW 20
#define COLUMN 10

NSInteger BOARD_W=280;
NSInteger BOARD_H=560;

NSInteger BLOCK_W_H=28;
NSInteger NEXT_BLOCK_W_H=18; //nextBlock


//下左右按钮长宽

NSInteger BUTTON_W_H=60;
//按钮的长宽

NSInteger BUTTON_W=80;
NSInteger BUTTON_H=80;

//label宽度
NSInteger LABELW=80;
//label高度
NSInteger LABELH=30;

//右侧按钮于Board间距
NSInteger MARGIN_H=10;
//右侧按钮纵向间距
NSInteger MARGIN_V=20;
//level开始位置
NSInteger LEVELSTART=180;

//nextBlock纵向开始位置
NSInteger NEXTBLOCK_H=105;

//左右下按钮左边距
NSInteger MARGIN_LEFT=10;
//左右下按钮下边距
NSInteger MARGIN_DOWN=80;

NSInteger FONT_SIZE=20;

NSInteger FONT_BIG_SIZE=60;

float pressTimerInterval = 0.06;



static SystemSoundID shake_sound_male_id = 0;


enum myTypes
{
    I_TYPE=0,
    S_TYPE,
    Z_TYPE,
    L_TYPE,
    J_TYPE,
    O_TYPE,
    T_TYPE
};

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setScreenScale];
    
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    
    //页面初始化
    
    //游戏开始、暂停页面
    [self initStartView];
    //游戏结束页面
    [self initGameOverView];
    //榜单页面填写名字
    [self initNameView];
    //榜单页面
    [self initRankView];
    //combo动画
    [self initComboView];
    //游戏结束，得分总结
    [self initNumbersView];
    //游戏存档填写名称页面
    [self initSaveGameView];
    
    _backgroundView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, VIEW_W, VIEW_H)];
    [_backgroundView setBackgroundColor:[UIColor lightGrayColor]];
    _backgroundView.userInteractionEnabled = YES;
    [self.view addSubview:_backgroundView];
    
    //board背景Image
    
    _boardImageView = [[UIImageView alloc]initWithFrame:CGRectMake(2, 2, BOARD_W, BOARD_H)];
    [_boardImageView setBackgroundColor:[UIColor blackColor]];
    [_backgroundView addSubview:_boardImageView];
    
    //数据初始化
    
    //新游戏开始
    [self initAllDataWithNewGame];
    
    
    //显示_liveBlock
    [self showLiveBlock];
    [self showNextBlock];
    
    //初始化按钮
    [self initButtons];
    
    _avPlayer = [self loadMusic];
    
    [_boardImageView addSubview:_comboBGView];
    [self.view addSubview:_gameoverView];
    [self.view addSubview:_startView];
    [_startView addSubview:_saveGameView];
    [self.view addSubview:_rankView];
    
    [self.view addSubview:_numbersView];
}

#pragma -mark 所有按钮点击方法
//数据统计页面确认按钮点击
-(void)numButtonTapped
{
    [_numbersView setHidden:YES];
    //是否需要入榜
    if ([self inTopRank]) {
        //上榜页面
        [_rankView setHidden:NO];
        [_nameView setHidden:NO];
    }
}

//排行榜页面关闭按钮
-(void)closeBtnTapped
{
    [_rankView setHidden:YES];
}

//姓名确认按钮
-(void)confirmBtnTapped
{
    [_nameText resignFirstResponder];
    [_nameView setHidden:YES];
    //将最新记录写入UserInfo.json文件
    [self writeToUserInfoFile];
    //更新排行榜显示
    [self updateRankView];
}

//点击空白页面，收回键盘
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [_nameText resignFirstResponder];
    [_gameNameField resignFirstResponder];
    return YES;
}
//点击回车，收回键盘
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_nameText resignFirstResponder];
    [_gameNameField resignFirstResponder];
    return YES;
}

//点击空白收回键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_nameText resignFirstResponder];
    [_gameNameField resignFirstResponder];
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    //左按钮
    if (point.x>_leftBtn.frame.origin.x && point.x<_leftBtn.frame.origin.x+BUTTON_W_H
        && point.y>_leftBtn.frame.origin.y && point.y<_leftBtn.frame.origin.y+BUTTON_W_H) {
        if([_pressTimer isValid])
        {
            [_pressTimer invalidate];
            _pressTimer = nil;
        }
        _pressTimer = [NSTimer scheduledTimerWithTimeInterval:pressTimerInterval target:self selector:@selector(leftBtnTapped) userInfo:nil repeats:YES];
    }
    //右按钮
    if (point.x>_rightBtn.frame.origin.x && point.x<_rightBtn.frame.origin.x+BUTTON_W_H
        && point.y>_rightBtn.frame.origin.y && point.y<_rightBtn.frame.origin.y+BUTTON_W_H) {
        if([_pressTimer isValid])
        {
            [_pressTimer invalidate];
            _pressTimer = nil;
        }
        _pressTimer = [NSTimer scheduledTimerWithTimeInterval:pressTimerInterval target:self selector:@selector(rightBtnTapped) userInfo:nil repeats:YES];
    }
    
    //下按钮
    if (point.x>_downBtn.frame.origin.x && point.x<_downBtn.frame.origin.x+BUTTON_W_H
        && point.y>_downBtn.frame.origin.y && point.y<_downBtn.frame.origin.y+BUTTON_W_H) {
        if([_pressTimer isValid])
        {
            [_pressTimer invalidate];
            _pressTimer = nil;
        }
        _pressTimer = [NSTimer scheduledTimerWithTimeInterval:pressTimerInterval target:self selector:@selector(downBtnTapped:) userInfo:nil repeats:YES];
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    //左按钮
    if (point.x>_leftBtn.frame.origin.x && point.x<_leftBtn.frame.origin.x+BUTTON_W_H
        && point.y>_leftBtn.frame.origin.y && point.y<_leftBtn.frame.origin.y+BUTTON_W_H) {
        if([_pressTimer isValid])
        {
            [_pressTimer invalidate];
        }
        _pressTimer = [NSTimer scheduledTimerWithTimeInterval:pressTimerInterval target:self selector:@selector(leftBtnTapped) userInfo:nil repeats:YES];
    }
    //右按钮
    if (point.x>_rightBtn.frame.origin.x && point.x<_rightBtn.frame.origin.x+BUTTON_W_H
        && point.y>_rightBtn.frame.origin.y && point.y<_rightBtn.frame.origin.y+BUTTON_W_H) {
        if([_pressTimer isValid])
        {
            [_pressTimer invalidate];
        }
        _pressTimer = [NSTimer scheduledTimerWithTimeInterval:pressTimerInterval target:self selector:@selector(rightBtnTapped) userInfo:nil repeats:YES];
    }
    //下按钮
    if (point.x>_downBtn.frame.origin.x && point.x<_downBtn.frame.origin.x+BUTTON_W_H
        && point.y>_downBtn.frame.origin.y && point.y<_downBtn.frame.origin.y+BUTTON_W_H) {
        if([_pressTimer isValid])
        {
            [_pressTimer invalidate];
        }
        _pressTimer = [NSTimer scheduledTimerWithTimeInterval:pressTimerInterval target:self selector:@selector(downBtnTapped:) userInfo:nil repeats:YES];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if([_pressTimer isValid])
    {
        [_pressTimer invalidate];
    }
}


//点击开始按钮
-(void)startBtnTapped
{
    
    [_startView setHidden:YES];
    if([_timer isValid])
    {
        [_timer invalidate];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0-(_level-1)/10.0 target:self selector:@selector(downBtnTapped:) userInfo:nil repeats:YES];
    [_avPlayer setVolume:0.3];
    if ([_musicSwitch isOn]) {
        [_avPlayer play];
    }
}

//点击暂停按钮
-(void)stopBtnClicked:(UIButton *)sender
{
    if ([_timer isValid]) {
        [_timer invalidate];
        [_startView setHidden:NO];
        [_avPlayer stop];
    }
}

//重置按钮
-(void)resetBtnTapped
{
    [_gameoverView setHidden:YES];
    [_board reset];
    [self updateBoard];
    [self newBlocks];
    [self showLiveBlock];
    [self showNextBlock];
    if([_timer isValid])
    {
        [_timer invalidate];
    }
    
    //数据清零
    [self numbersClear];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0-(_level-1)/10.0 target:self selector:@selector(downBtnTapped:) userInfo:nil repeats:YES];
    
    [self readUserInfos];
    
    //排行榜
    _nameText.text = @"";

    if ([_musicSwitch isOn]) {
        [_avPlayer play];
    }
    [self updateLabels];
}

-(void)leftBtnTapped
{
    if ([_soundSwitch isOn]) {
        [self playSound:1];
    }
    [self moveOrRotate:1];
    [self showLiveBlock];
}

-(void)rightBtnTapped
{
    if ([_soundSwitch isOn]) {
        [self playSound:1];
    }
    [self moveOrRotate:2];
    [self showLiveBlock];
}

-(void)downBtnTapped:(id)sender
{
    if ([_soundSwitch isOn]) {
        
        if (![sender isKindOfClass:[NSTimer class]]) {
            [self playSound:1];
        }
        else if([[sender userInfo] isEqualToString:@"1"])
        {
            [self playSound:1];
        }

    }
    [self moveOrRotate:3];
    [self showLiveBlock];
}


-(void)rotateBtnTapped
{
//    [UMSocialSnsService presentSnsIconSheetView:self appKey:@"56582b6367e58ec04b0018c5" shareText:@"你要分享的文字" shareImage:[UIImage imageNamed:@"icon.png"] shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatTimeline,UMShareToWechatSession,nil] delegate:nil];
    if ([_soundSwitch isOn]) {
        [self playSound:1];
    }
    [self moveOrRotate:4];
    [self showLiveBlock];
}

-(void)leftLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        if([_pressTimer isValid])
        {
            [_pressTimer invalidate];
        }
        _pressTimer = [NSTimer scheduledTimerWithTimeInterval:pressTimerInterval target:self selector:@selector(leftBtnTapped) userInfo:nil repeats:YES];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        [_pressTimer invalidate];
    }
}

-(void)downLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        if([_pressTimer isValid])
        {
            [_pressTimer invalidate];
        }
        _pressTimer = [NSTimer scheduledTimerWithTimeInterval:pressTimerInterval target:self selector:@selector(downBtnTapped:) userInfo:@"1" repeats:YES];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        [_pressTimer invalidate];
    }
}

-(void)rightLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        if([_pressTimer isValid])
        {
            [_pressTimer invalidate];
        }
        _pressTimer = [NSTimer scheduledTimerWithTimeInterval:pressTimerInterval target:self selector:@selector(rightBtnTapped) userInfo:nil repeats:YES];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        [_pressTimer invalidate];
    }
}

-(void)rotateLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        if([_pressTimer isValid])
        {
            [_pressTimer invalidate];
        }
        _pressTimer = [NSTimer scheduledTimerWithTimeInterval:pressTimerInterval target:self selector:@selector(rotateBtnTapped) userInfo:nil repeats:YES];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        [_pressTimer invalidate];
    }
}

-(BOOL)moveOrRotate:(NSInteger)dir
{
    //先移动，后判断，如果判断不通过则逆向操作
    
    //dir 1 2 3 4 代表左右下转
    switch (dir) {
        case 1:
            [_liveBlock moveLeft];
            break;
        case 2:
            [_liveBlock moveRight];
            break;
        case 3:
            [_liveBlock moveDown];
            break;
        case 4:
            [_liveBlock rotate];
            break;
            
        default:
            break;
    }
    
    int x = _liveBlock.point.h;
    int y = _liveBlock.point.v;
    
    for (int i=0; i<[_liveBlock.square count]; i++) {
        for (int j=0; j<[_liveBlock.square[i] count]; j++) {
            //_liveBlock不为0时，_liveBlock碰到左右两侧或者底边 或者 _liveBlock碰到Borad square中的其它方块时
            //逆向操作
            //当触底时，产生新的方块
            if ([_liveBlock.square[i][j] intValue]!=0 &&
                ((i+x>=ROW || j+y<0 || j+y>=COLUMN)
                 || (i+x>=0 && [[_board square][i+x+1][j+y+1]intValue]!=0)))
            {
                switch (dir) {
                    case 1:
                        [_liveBlock moveRight];
                        break;
                    case 2:
                        [_liveBlock moveLeft];
                        break;
                    case 3:
                        [_liveBlock moveUp];//触底
                        [self touchedBottom];
                        break;
                    case 4:
                        [_liveBlock clockwiseRotate];
                        break;
                        
                    default:
                        break;
                }
                return false;
            }
        }
    }
    return true;
}


#pragma -mark Engine

//判断是否需要入榜
-(BOOL)inTopRank
{
    //榜上小于10位，直接上榜
    if (_userInfoArray.count<10) {
        return YES;
    }
    return _score > [[_userInfoArray[9] allKeys][0] intValue];
}
//读取沙盒中userInfo文件数据，存到_userInfoArray数组中
-(void)readUserInfos
{
    _userInfoArray = [[NSMutableArray alloc]init];
    NSFileManager * manager = [[NSFileManager alloc]init];
    NSString * docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString * archiveFilePath = [docPath stringByAppendingPathComponent:@"userInfo"];
    if(![manager fileExistsAtPath:archiveFilePath])//filePath
    {
        _topScore = 0;
        BOOL rect = [manager createFileAtPath:archiveFilePath contents:nil attributes:nil];
        if (!rect) {
            NSLog(@"文件创建失败");
        }
        return;
    }
    _userInfoArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePath]];
    
    if (_userInfoArray.count!=0) {

        _topScore = [[_userInfoArray[0] allKeys][0] intValue];
    }
    
}

//将当前用户信息插入到用户数据文件中，写入沙盒userInfo文件
-(void)writeToUserInfoFile
{
    //只保留前10位用户
    if (_userInfoArray.count >= 10) {
        [_userInfoArray removeObjectAtIndex:9];
    }
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:_nameText.text forKey:[NSString stringWithFormat:@"%lu",_score]];
    int i=0;
    for (; i<_userInfoArray.count; i++) {
        if(_score >= [[_userInfoArray[i] allKeys][0] intValue])
        {
            [_userInfoArray insertObject:dic atIndex:i];
            break;
        }
    }
    if (i==_userInfoArray.count) {
        [_userInfoArray insertObject:dic atIndex:i];
    }
    //获取文件路径
    NSString * docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSString * archiveFilePath = [docPath stringByAppendingPathComponent:@"userInfo"];
    
    //归档
    BOOL rect = [NSKeyedArchiver archiveRootObject:_userInfoArray toFile:archiveFilePath];
    if(rect)
    {
        NSLog(@"用户数据归档成功");
    }
}

//将UserInfoArray中数据显示到rankView中
-(void)updateRankView
{
    for (int i=0; i<_userInfoArray.count; i++) {
        for (NSString * score in _userInfoArray[i]) {
            NSString * name = [_userInfoArray[i] objectForKey:score];
            [_rankLabelArray[i+1][1] setText:name];
            [_rankLabelArray[i+1][2] setText:score];
        }
    }

}

//播放音效
-(void)playSound:(NSInteger)type
{
    NSURL *url = nil;
    switch (type) {
        case 1://落方块，点击向左、向右、向下，以及旋转按钮
            url = [[NSBundle mainBundle] URLForResource:@"hit.mp3" withExtension:nil];
            break;
        case 2://消行
            url = [[NSBundle mainBundle] URLForResource:@"俄罗斯方块-消行.mp3" withExtension:nil];
            break;
        case 3://game over
            url = [[NSBundle mainBundle] URLForResource:@"俄罗斯方块-失败.mp3" withExtension:nil];
            break;
            
        default:
            break;
    }
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &shake_sound_male_id);
    AudioServicesPlaySystemSound(shake_sound_male_id);
}
//触底后续操作
-(void)touchedBottom
{
    if ([self isTouchedTop]) {
        //GAME VOER
        [self gameOver];
        
        return;
    }
    [self writeLiveBlockToBoard];
    [self newBlocks];
    [self showLiveBlock];
    [self showNextBlock];
    [self eliminate];
}

//游戏结束
-(void)gameOver
{
    [_avPlayer stop];
    if ([_soundSwitch isOn]) {
        [self playSound:3];
    }
    [_timer invalidate];
    [_gameoverView setHidden:NO];
    
    [self updateNumberView];
    [_numbersView setHidden:NO];
    
}

//判断是否触顶
-(BOOL)isTouchedTop
{
    int x = _liveBlock.point.h;
    for (int i=0; i<[_liveBlock.square count]; i++) {
        for (int j=0; j<[_liveBlock.square[i] count]; j++) {
            //_liveBlock不为0时，_liveBlock碰到左右两侧或者底边 或者 _liveBlock碰到Borad square中的其它方块时
            //逆向操作
            //当触底时，产生新的方块
            if ([_liveBlock.square[i][j] intValue]!=0 &&
                i+x<=0)
            {
                return YES;
            }
        }
    }
    return NO;
}

//将_liveBlock square写到Board square中去
-(void)writeLiveBlockToBoard
{
    int x = _liveBlock.point.h;//行
    int y = _liveBlock.point.v;//列
    for (int i=0; i<_liveBlock.square.count; i++) {
        for (int j=0; j<[_liveBlock.square[i] count]; j++) {
            if ([[_liveBlock square][i][j] intValue] !=0) {
                [_board square][i+x+1][j+y+1]=[_liveBlock square][i][j];

            }
        }
    }
    [self updateBoard];
}


//查找所有需要消除的行，并消除
-(void)eliminate
{
    //连击次数
    static int combo = 0;
    
    NSMutableArray * rowsArray = [[NSMutableArray alloc]init];
    for (int i=1; i<ROW+1; i++) {
        for (int j=1; j<COLUMN+1; j++) {
            if ([[_board square][i][j] isEqualToString:@"0"]) {
                break;
            }
            if (j==10) {
                [rowsArray addObject:[NSString stringWithFormat:@"%d",i]];
            }
        }
    }
    if (rowsArray.count!=0) {
        combo++;
        //记录最大combo值（数据统计）
        if (combo > _comboCount) {
            _comboCount = combo;
        }
        
        //显示combo动画
        if (combo>1) {
            [self showCombo:combo];
        }
        
        if ([_soundSwitch isOn]) {
            [self playSound:2];
        }
        
        for (int i=0; i<rowsArray.count ; i++) {
            [self eliminateOneLine:[rowsArray[i] intValue]];
        }
        
//        if([_flashTimer isValid])
//        {
//            [_flashTimer invalidate];
//        }
//        _flashTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(eliminateFlash:) userInfo:rowsArray repeats:YES];
        switch (rowsArray.count) {
            case 1:
                _score += 10*combo;
                break;
            case 2:
                _score += 25*combo;
                break;
            case 3:
                _score += 50*combo;
                break;
            case 4:
                _score += 100*combo;
                break;
            default:
                break;
        }
        if (_score > _topScore) {
            _topScore = _score;
        }
        _rows += rowsArray.count;
        float tmp = _score/1000 + 1;
        if (tmp != _level) {
            _level = tmp;
            [_timer invalidate];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0-(_level-1)/10.0 target:self selector:@selector(downBtnTapped:) userInfo:nil repeats:YES];
        }
        [self updateLabels];
        
        //数据统计
        switch (rowsArray.count) {
            case 1:
                _oneCount++;
                break;
            case 2:
                _twoCount++;
                break;
            case 3:
                _threeCount++;
                break;
            case 4:
                _fourCount++;
                break;
                
            default:
                break;
        }
    }
    else
    {
        combo = 0;
        if ([_soundSwitch isOn]) {
            [self playSound:1];
        }
    }
    
}

//-(void)eliminateFlash:(id)sender
//{
//    static int c = 1;
//    
//    NSArray * array = [sender userInfo];
//    
//    for (int i=0; i<array.count; i++) {
//        for (int j=0; j<COLUMN; j++) {
//            [self setImage:_boardArray[[array[i] intValue]-1][j] withColor:c];
//
//        }
//    }
//    
//    c++;
//    if (c==4) {
//        [_flashTimer invalidate];
//        for (int i=0; i<array.count ; i++) {
//            [self eliminateOneLine:[array[i] intValue]];
//        }
//        c=0;
//    }
//}

//消除指定一行
-(void)eliminateOneLine:(int)index
{
    [self eliminateOneFlash:index];
    
    NSMutableArray * array = [NSMutableArray arrayWithArray:[_board square][index]];
    for (int i=index; i>1; i--) {
        [_board square][i] = [NSMutableArray arrayWithArray:[_board square][i-1]];
    }
    for (int i=1; i<11; i++) {
        array[i] = @"0";
    }
    [_board square][1] = [NSMutableArray arrayWithArray:array];
    [self updateBoard];
}

-(void)eliminateOneFlash:(int)index
{
    [UIView beginAnimations:nil context:nil ];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    
    for (int i=0; i<10; i++) {
        [_boardArray[index-1][i] setAlpha:0];
        [_boardArray[index-1][i] setAlpha:1];
    }
    
    [UIView commitAnimations];
}

#pragma -mark 界面显示

-(void)setScreenScale
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    float scale = 1.0;
    switch ((int)screenHeight) {
        case 480://iphone4 4s 960*640
            scale = 0.7;
            break;
        case 568://iphone 5 5s 1136*640
            scale = 0.78;
            break;
        case 667://iphone 6 6s 1334*750
            scale = 0.9;
            break;
        case 960://iphone 6P 6s Plus 1920*1080
            break;
        case 1024://ipad air 1024
            scale = 1.35;
            break;
            
        default:
            break;
    }
    
    BLOCK_W_H *= scale;
    NEXT_BLOCK_W_H *= scale; //nextBlock
    
    BOARD_W = BLOCK_W_H * COLUMN;
    BOARD_H = BLOCK_W_H * ROW;
    
    BUTTON_W_H *= scale;
    BUTTON_W *= scale;
    BUTTON_H *= scale;
    LABELW *= scale;
    LABELH *= scale;
    MARGIN_H *= scale;
    MARGIN_V *= scale;
    MARGIN_LEFT *= scale;
    MARGIN_DOWN *= scale;
    FONT_SIZE *= scale;
    FONT_BIG_SIZE *= scale;
}

#pragma -mark 数据初始化
//
-(void)initAllDataWithNewGame
{
    //初始化背景面板_boardArray
    [self initBoardArray];
    //随机生成_liveBlock _nextBlock对象
    [self newBlocks];
    //初始化liveImageView、nextImageView数组
    [self initLiveAndNextImageArray];
    //初始化统计数据
    [self numbersClear];
}

//数据清零
-(void)numbersClear
{
    _score = 0;
    _level = 1;
    _rows = 0;
    _oneCount = 0;
    _twoCount = 0;
    _threeCount = 0;
    _fourCount = 0;
    _comboCount = 0;
}
//更新数据统计页面数据
-(void)updateNumberView
{
    NSArray * valueArray = [NSArray arrayWithObjects:
                            [NSString stringWithFormat:@"%lu", _level],
                            [NSString stringWithFormat:@"%lu", _score],
                            [NSString stringWithFormat:@"%lu", _rows],
                            [NSString stringWithFormat:@"%lu", _oneCount],
                            [NSString stringWithFormat:@"%lu", _twoCount],
                            [NSString stringWithFormat:@"%lu", _threeCount],
                            [NSString stringWithFormat:@"%lu", _fourCount],
                            [NSString stringWithFormat:@"%lu", _comboCount], nil];
    for (int i=0; i<4; i++) {
        for (int j=0; j<4; j++) {
            if (j%2==1) {
                [_labelsArray[i][j] setText:valueArray[i*2+(j-1)/2]];
            }
            
        }
    }
}

//刷新显示面板
-(void)updateBoard
{
    for (int i=0; i<ROW; i++) {
        for (int j=0; j<COLUMN; j++) {
            int color = [[_board square][i+1][j+1] intValue];
            [self setImage:_boardArray[i][j] withColor:color];
        }
    }
}

//显示_liveBlock
-(void)showLiveBlock
{
    int x = [_liveBlock point].h;
    int y = [_liveBlock point].v;
    int c = 0;
    for (int i=0; i<[_liveBlock.square count]; i++) {
        for(int j=0;j<[_liveBlock.square[i] count];j++)
        {
            if ([_liveBlock.square[i][j] intValue] != 0) {
                [_liveImageArray[c] setFrame:CGRectMake((j+y)*BLOCK_W_H, (i+x)*BLOCK_W_H, BLOCK_W_H, BLOCK_W_H)];
                c++;
            }
        }
    }
}

//显示_nextBlock
-(void)showNextBlock
{
    int c = 0;
    
    //调节nextblock显示位置
    NSInteger leftMargin = _boardImageView.frame.size.width + _boardImageView.frame.origin.x;
    NSInteger topMargin = _boardImageView.frame.origin.y + MARGIN_V*2 + LABELH;
//    NSInteger width = _nextBlock.square.count;
//    if(width==3 && _nextBlock.square[0][0]==0 && _nextBlock.square[1][0]==0 && _nextBlock.square[2][0]== 0)
//    {
//        leftMargin *= -1.6;
//    }
//    else if(width==3 && _nextBlock.square[0][2]==0 && _nextBlock.square[1][2]==0 && _nextBlock.square[2][2]== 0)
//    {
//        leftMargin *= 9;
//    }
//    else if(width ==2)//方块
//    {
//        leftMargin *= 1.7;
//    }
//    else if(width==4 && _nextBlock.square[1][0] != 0) //横条
//    {
//        leftMargin *= 1.0;
//    }
//    else if(width==4 && _nextBlock.square[0][1] != 0) //竖条
//    {
//        leftMargin *= 5;
//    }
//    else//3*3横向
//    {
//        leftMargin *= 1.35;
//    }
    for (int i=0; i<[_nextBlock.square count]; i++) {
        for(int j=0;j<[_nextBlock.square[i] count];j++)
        {
            if ([_nextBlock.square[i][j] intValue] != 0) {
                [_nextImageArray[c] setFrame:CGRectMake(leftMargin+MARGIN_H+j*NEXT_BLOCK_W_H,  topMargin+i*NEXT_BLOCK_W_H, NEXT_BLOCK_W_H, NEXT_BLOCK_W_H)];
                c++;
            }
        }
    }
}

//刷新labels显示
-(void)updateLabels
{
    [_topLabel setText:[NSString stringWithFormat:@"%lu",(long)_topScore]];
    [_scoreLabel setText:[NSString stringWithFormat:@"%lu",(long)_score]];
    [_levelLabel setText:[NSString stringWithFormat:@"%lu",(long)_level]];
    [_rowLabel setText:[NSString stringWithFormat:@"%lu",(long)_rows]];
}


#pragma -mark 控件、界面初始化
//初始化数据显示页面
-(void)initNumbersView
{
    _numbersView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, VIEW_W, VIEW_H)];
    [_numbersView setBackgroundColor:[UIColor blackColor]];
    [_numbersView setUserInteractionEnabled:YES];
    [_numbersView setHidden:YES];
    
    int tableWidth = VIEW_W*0.8;
    int tableHeight = VIEW_H*0.6;
    int H_Margin = 10;//水平间距
    int V_Margin = 50;//纵向间距
    int LeftMargin = (VIEW_W-tableWidth)/2;//左边间距
    int TopMargin = (VIEW_H-tableHeight)/2;//顶边间距
    
    NSArray * array = @[@"等级",@"总分",@"总行数",@"1行",@"2行",@"3行",@"4行",@"最大连击"];
    NSArray * valueArray = [NSArray arrayWithObjects:
                            [NSString stringWithFormat:@"%lu", _level],
                            [NSString stringWithFormat:@"%lu", _score],
                            [NSString stringWithFormat:@"%lu", _rows],
                            [NSString stringWithFormat:@"%lu", _oneCount],
                            [NSString stringWithFormat:@"%lu", _twoCount],
                            [NSString stringWithFormat:@"%lu", _threeCount],
                            [NSString stringWithFormat:@"%lu", _fourCount],
                            [NSString stringWithFormat:@"%lu", _comboCount], nil];
    
    _labelsArray = [[NSMutableArray alloc]init];
    for (int i=0; i<4; i++) {
        NSMutableArray * tmp = [[NSMutableArray alloc]init];
        for (int j=0; j<4; j++) {
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(LeftMargin+j*(LABELW+H_Margin), TopMargin+i*(LABELH+V_Margin), LABELW, LABELH)];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setTextColor:[UIColor whiteColor]];
            if (j%2==0) {
                [label setBackgroundColor:[UIColor darkGrayColor]];
                [label setText:array[i*2+j/2]];
            }
            else
            {
                [label setText:valueArray[i*2+(j-1)/2]];
            }
            [tmp addObject:label];
            [_numbersView addSubview:label];
        }
        [_labelsArray addObject:tmp];
    }
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake((VIEW_W-LABELW*2)/2, VIEW_H*0.8, LABELW*2, LABELH*1.6)];
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor darkGrayColor]];
    [btn addTarget:self action:@selector(numButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_numbersView addSubview:btn];
}

//初始化combo页面
-(void)initComboView
{
    int comboBGViewWidth = BOARD_W * 0.6;
    int comboBGViewHight = BOARD_H * 0.15;
    
    int comboViewWidth = comboBGViewWidth * 0.6;
    int comboViewHight = comboBGViewHight * 0.4;
    
    NSInteger M_L = (BOARD_W-comboViewWidth)/3;
    NSInteger M_T = (BOARD_H-comboViewHight)/5;
    
    _comboBGView = [[UIImageView alloc]initWithFrame:CGRectMake(M_L, M_T, comboBGViewWidth, comboBGViewHight)];
    UIImageView * comboView = [[UIImageView alloc]initWithFrame:CGRectMake(0, comboBGViewHight/3, comboViewWidth, comboViewHight)];
    
    _comboCountView = [[UIImageView alloc]initWithFrame:CGRectMake(comboViewWidth, 0, comboBGViewWidth-comboViewWidth, comboBGViewHight)];
    [_comboCountView setImage:[UIImage imageNamed:@"X1"]];
    [comboView setImage:[UIImage imageNamed:@"combo"]];
    
    [_comboBGView addSubview:comboView];
    [_comboBGView addSubview:_comboCountView];
    [_comboBGView setAlpha:0.0];
    
}

//设置combo的count
-(void)setComboView:(NSInteger)count
{
    switch (count) {
        case 1:
            [_comboCountView setImage:[UIImage imageNamed:@"X1"]];
            break;
        case 2:
            [_comboCountView setImage:[UIImage imageNamed:@"X2"]];
            break;
        case 3:
            [_comboCountView setImage:[UIImage imageNamed:@"x3"]];
            break;
        case 4:
            [_comboCountView setImage:[UIImage imageNamed:@"x4"]];
            break;
        case 5:
            [_comboCountView setImage:[UIImage imageNamed:@"x5"]];
            break;
        case 6:
            [_comboCountView setImage:[UIImage imageNamed:@"x6"]];
            break;
        case 7:
            [_comboCountView setImage:[UIImage imageNamed:@"x7"]];
            break;
        case 8:
            [_comboCountView setImage:[UIImage imageNamed:@"x8"]];
            break;
        case 9:
            [_comboCountView setImage:[UIImage imageNamed:@"x9"]];
            break;
        case 10:
            [_comboCountView setImage:[UIImage imageNamed:@"x10"]];
            break;
        case 11:
            [_comboCountView setImage:[UIImage imageNamed:@"x11"]];
            break;
        case 12:
            [_comboCountView setImage:[UIImage imageNamed:@"x12"]];
            break;
        case 13:
            [_comboCountView setImage:[UIImage imageNamed:@"x13"]];
            break;
        case 14:
            [_comboCountView setImage:[UIImage imageNamed:@"x14"]];
            break;
        case 15:
            [_comboCountView setImage:[UIImage imageNamed:@"x15"]];
            break;
        case 16:
            [_comboCountView setImage:[UIImage imageNamed:@"x16"]];
            break;
        case 17:
            [_comboCountView setImage:[UIImage imageNamed:@"x17"]];
            break;
        case 18:
            [_comboCountView setImage:[UIImage imageNamed:@"x18"]];
            break;
        case 19:
            [_comboCountView setImage:[UIImage imageNamed:@"x19"]];
            break;
        case 20:
            [_comboCountView setImage:[UIImage imageNamed:@"x20"]];
            break;
            
        default:
            break;
    }
}

//显示combo动画
-(void)showCombo:(NSInteger)count
{
    //设置并显示comoboView
    [self setComboView:count];
    [UIView beginAnimations:nil context:nil ];
    [UIView setAnimationDuration:2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

    _comboBGView.alpha = 1.0;
    _comboBGView.alpha = 0.0;
    
    [UIView commitAnimations];
}

//初始化榜单页面
-(void)initRankView
{
    int tableWidth = VIEW_W*0.8;
    int tableHeight = VIEW_H*0.8;
    int M_H = 25;//水平间距
    int M_V = 20;//纵向间距
    int M_L = (VIEW_W-tableWidth)/2;//左边间距
    int M_T = (VIEW_H-tableHeight)/2;//顶边间距
    _rankView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [_rankView setBackgroundColor:[UIColor whiteColor]];
    [_rankView setUserInteractionEnabled:YES];
    [_rankView setHidden:YES];
    
    //关闭（隐藏）页面按钮
    UIButton * closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setFrame:CGRectMake(VIEW_W-60, 20, 40, 40)];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"关闭.jpg"] forState:UIControlStateNormal];
    
    closeBtn.layer.cornerRadius = 20;
    [closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [_rankView addSubview:closeBtn];
    
    _rankLabelArray = [[NSMutableArray alloc]init];
    
    for (int i=0; i<11; i++) {
        NSMutableArray * tmpArray = [[NSMutableArray alloc] init];
        for (int j=0; j<3; j++) {
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(M_L+j*(LABELW*1.2+M_H),M_T+i*(LABELH*1.2+M_V), LABELW*1.2, LABELH*1.2)];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFont:[UIFont fontWithName:@"Helvetica" size:FONT_SIZE]];
            [label setBackgroundColor:[UIColor lightGrayColor]];
            if (i!=0 && j==0) {
                [label setText:[NSString stringWithFormat:@"%d",i]];
            }
            [tmpArray addObject:label];
            [_rankView addSubview:label];
        }
        [_rankLabelArray addObject:tmpArray];
    }
    [_rankLabelArray[0][1] setText:@"姓名"];
    [_rankLabelArray[0][2] setText:@"得分"];
    [self initNameView];
    [_rankView addSubview:_nameView];
    
    [self readUserInfos];
    [self updateRankView];
}


//初始化上榜页面
-(void)initNameView
{
    _nameView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W-100, VIEW_W*0.3)];
    [_nameView setBackgroundColor:[UIColor blackColor]];
    [_nameView setUserInteractionEnabled:YES];
    [_nameView setHidden:YES];
    _nameView.center = _rankView.center;
    
    //填写名字
    UILabel * tmpLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, LABELH, LABELW, LABELH)];
    [tmpLabel setText:@"名字"];
    [tmpLabel setTextColor:[UIColor whiteColor]];
    [tmpLabel setFont:[UIFont fontWithName:@"Helvetica" size:FONT_SIZE]];
    [tmpLabel setTextAlignment:NSTextAlignmentCenter];
    [_nameView addSubview:tmpLabel];
    
    _nameText = [[UITextField alloc]initWithFrame:CGRectMake(10+LABELW, LABELH, LABELW*2, LABELH)];
    [_nameText setTextColor:[UIColor blackColor]];
    [_nameText setBackgroundColor:[UIColor lightGrayColor]];
    [_nameText setFont:[UIFont fontWithName:@"Helvetica" size:FONT_SIZE]];
    [_nameText setTextAlignment:NSTextAlignmentCenter];
    [_nameView addSubview:_nameText];
    _nameText.delegate = self;

    
    //确认
    UIButton * confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn setFrame:CGRectMake((VIEW_W-100)/2-LABELW/2, LABELH*2+10, LABELW, LABELH)];
    [confirmBtn setBackgroundColor:[UIColor whiteColor]];
    [confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_nameView addSubview:confirmBtn];

}

//初始化start页面
-(void)initGameOverView
{
    _gameoverView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [_gameoverView setBackgroundColor:[UIColor whiteColor]];
    UIButton * resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [resetBtn setBackgroundColor:[UIColor blackColor]];
    [resetBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [resetBtn setTitle:@"重新开始" forState:UIControlStateNormal];
    [resetBtn setFrame:CGRectMake(VIEW_W/2-LABELW, VIEW_H-BUTTON_H*6, LABELW*2, BUTTON_H*2)];
    [resetBtn addTarget:self action:@selector(resetBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    UILabel * gameoverLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, VIEW_W, VIEW_H-100)];
    [gameoverLabel setText:@"GAME OVER"];
    [gameoverLabel setTextColor:[UIColor redColor]];
    [gameoverLabel setFont:[UIFont fontWithName:@"Helvetica" size:FONT_BIG_SIZE]];
    [gameoverLabel setTextAlignment:NSTextAlignmentCenter];
    _gameoverView.alpha = 0.5;
    [_gameoverView addSubview:gameoverLabel];
    [_gameoverView setUserInteractionEnabled:YES];
    [_gameoverView addSubview:resetBtn];
    [_gameoverView setHidden:YES];
}

//初始化游戏开始界面
-(void)initStartView
{
    _startView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [_startView setBackgroundColor:[UIColor whiteColor]];
    
    [_startView setUserInteractionEnabled:YES];
    [_startView setAlpha:0.9];
    UIButton * startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [startButton setFrame:CGRectMake((VIEW_W-LABELW*2)/2, VIEW_H-LABELW*2, LABELW*2, BUTTON_H)];
    [startButton setBackgroundColor:[UIColor blackColor]];
    [startButton setTitle:@"开始游戏" forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(startBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [_startView addSubview:startButton];
    
    //音乐开关
    UILabel * musicLabel = [[UILabel alloc]initWithFrame:CGRectMake((VIEW_W-LABELW*2)/2, LABELW*3, LABELW*2, LABELH)];
    [musicLabel setFont:[UIFont fontWithName:@"Helvetica" size:FONT_SIZE]];
    [musicLabel setText:@"背景音乐"];
    _musicSwitch = [[UISwitch alloc]initWithFrame:CGRectMake((VIEW_W-LABELW*2)/2+LABELW+LABELH, LABELW*3, BUTTON_W, BUTTON_H/4)];
    
    //音效开关
    UILabel * soundLabel = [[UILabel alloc]initWithFrame:CGRectMake((VIEW_W-LABELW*2)/2, LABELW*3+BUTTON_H, LABELW*2, LABELH)];
    [soundLabel setFont:[UIFont fontWithName:@"Helvetica" size:FONT_SIZE]];
    [soundLabel setText:@"音效"];
    _soundSwitch = [[UISwitch alloc]initWithFrame:CGRectMake((VIEW_W-LABELW*2)/2+LABELW+LABELH, LABELW*3+BUTTON_H, BUTTON_W, BUTTON_H/4)];
    [_startView addSubview:soundLabel];
    [_startView addSubview:_soundSwitch];
    [_startView addSubview:musicLabel];
    [_startView addSubview:_musicSwitch];
    
    //打开游戏存档页面按钮
    UIButton * openLoadFileViewBtn = [[UIButton alloc]initWithFrame:CGRectMake((VIEW_W-LABELW*2)/2, LABELW*3+BUTTON_H*2, LABELW*2, LABELH)];
    [openLoadFileViewBtn setTitle:@"读取游戏进度" forState:UIControlStateNormal];
    [openLoadFileViewBtn setBackgroundColor:[UIColor blackColor]];
    [openLoadFileViewBtn addTarget:self action:@selector(openLoadFileViewBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [_startView addSubview:openLoadFileViewBtn];

    //将当前游戏存档按钮
    UIButton * saveGameBtn = [[UIButton alloc]initWithFrame:CGRectMake((VIEW_W-LABELW*2)/2, LABELW*3+BUTTON_H*3, LABELW*2, LABELH)];
    [saveGameBtn setTitle:@"保存游戏进度" forState:UIControlStateNormal];
    [saveGameBtn setBackgroundColor:[UIColor blackColor]];
    [saveGameBtn addTarget:self action:@selector(saveGameBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [_startView addSubview:saveGameBtn];
    
}

#pragma -mark 游戏存档-按钮点击事件

//存储游戏取消按钮
-(void)saveGameNameCancelBtnTapped
{  
    _gameNameField.text = @"";
    [_saveGameView setHidden:YES];
}

//存储游戏填写名称，点击确认
-(void)saveGameNameBtnTapped
{
    [_gameNameField resignFirstResponder];
    [_saveGameView setHidden:YES];
    if ([self writeGameToFile:_gameNameField.text]) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"保存成功" message:@"游戏进度保存成功" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:confirmAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"保存失败" message:@"游戏进度保存失败" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:confirmAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    _gameNameField.text = @"";
}

//保存游戏进度按钮点击
-(void)saveGameBtnTapped
{
    [_saveGameView setHidden:NO];
}

//游戏存档页面，点击某个游戏存档按钮
-(void)loadFileViewBtnOneTapped
{
    [self initGameFormFile:0];
    [_loadFilesView setHidden:YES];
}
-(void)loadFileViewBtnTwoTapped
{
    [self initGameFormFile:1];
    [_loadFilesView setHidden:YES];
}
-(void)loadFileViewBtnThreeTapped
{
    [self initGameFormFile:2];
    [_loadFilesView setHidden:YES];
}
-(void)loadFileViewBtnFourTapped
{
    [self initGameFormFile:3];
    [_loadFilesView setHidden:YES];
}
-(void)loadFileViewBtnFiveTapped
{
    [self initGameFormFile:4];
    [_loadFilesView setHidden:YES];
}

//startView页面：点击游戏存档按钮，显示游戏存档页面
-(void)openLoadFileViewBtnTapped
{
    [self showLoadFilesView];
    
}

-(void)loadFileViewReturnBtnTapped
{
    [_loadFilesView setHidden:YES];
}

#pragma -mark 初始化并显示存档信息界面

//初始化游戏存档页面
-(void)showLoadFilesView
{
    if (_loadFilesView) {
        _loadFilesView = nil;
    }
    //读取游戏进度到allGamesArray
    [self readGameFromFile];
    
    
    //初始化所有界面空间
    _loadFilesView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, VIEW_W, VIEW_H)];
    [_loadFilesView setBackgroundColor:[UIColor blackColor]];
    [_loadFilesView setUserInteractionEnabled:YES];
    
    int width = VIEW_W * 0.9;
    int height = VIEW_H * 0.5;
    int left_Margin = (VIEW_W - width)/2;
    int top_Margin = (VIEW_H-height)/2;
    int Margin_V = height/5;
    
    if (_allGameArray.count == 0) {
        UILabel * noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(left_Margin, top_Margin, width, height)];
        [noDataLabel setTextAlignment:NSTextAlignmentCenter];
        [noDataLabel setText:@"没有存档"];
        [noDataLabel setTextColor:[UIColor whiteColor]];
        [noDataLabel setFont:[UIFont fontWithName:@"Helvetica" size:FONT_BIG_SIZE]];
        [_loadFilesView addSubview:noDataLabel];
    }
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake((VIEW_W-LABELW)/2, VIEW_H*0.8, LABELW, LABELH)];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(loadFileViewReturnBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [_loadFilesView addSubview:button];
    
    
    for (int i=0; i<_allGameArray.count; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:_allGameArray[i][6] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(left_Margin, top_Margin + i*Margin_V, LABELW*2, LABELH)];
        [button setBackgroundColor:[UIColor darkGrayColor]];
        [_loadFilesView addSubview:button];
        switch (i) {
            case 0:
                [button addTarget:self action:@selector(loadFileViewBtnOneTapped) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 1:
                [button addTarget:self action:@selector(loadFileViewBtnTwoTapped) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 2:
                [button addTarget:self action:@selector(loadFileViewBtnThreeTapped) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 3:
                [button addTarget:self action:@selector(loadFileViewBtnFourTapped) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 4:
                [button addTarget:self action:@selector(loadFileViewBtnFiveTapped) forControlEvents:UIControlEventTouchUpInside];
                break;
            default:
                break;
        }
        
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(left_Margin + LABELW*2, top_Margin + i*Margin_V, LABELW*3, LABELH)];
        [label setText:_allGameArray[i][7]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:[UIColor lightGrayColor]];
        [label setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [_loadFilesView addSubview:label];
    }
    [_startView addSubview:_loadFilesView];
}

//读取_allGameArray中第index个存档
-(void)initGameFormFile:(NSInteger)index
{
    NSArray * gameArray = [_allGameArray objectAtIndex:index];
    
    _board.square = [NSMutableArray arrayWithArray:[gameArray objectAtIndex:0]];
    _liveBlock = [gameArray objectAtIndex:1];
    _nextBlock = [gameArray objectAtIndex:2];
    _level = [[gameArray objectAtIndex:3] intValue];
    _score = [[gameArray objectAtIndex:4] intValue];
    _rows = [[gameArray objectAtIndex:5]intValue];
    
    [self updateBoard];
    [self showLiveBlock];
    [self showNextBlock];
    [self updateLabels];
}

//读取游戏存档文件
-(void)readGameFromFile
{
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"GameUserData"];
    
    _allGameArray = [[NSMutableArray alloc]init];
    NSFileManager * manager = [NSFileManager defaultManager];
    //如果已有存档，读取存档文件
    if ([manager fileExistsAtPath:path]) {
        _allGameArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:path]];
    }
}

//将当前游戏存档
-(BOOL)writeGameToFile:(NSString *)gameName
{
    [self readGameFromFile];
    
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"GameUserData"];

    //获取当前时间
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH点mm分ss秒"];
    NSString * dateNow = [dateFormatter stringFromDate:[NSDate date]];
    
    //将当前游戏数据写入数组
    NSMutableArray * thisGameArray = [[NSMutableArray alloc]initWithObjects:_board.square,_liveBlock,_nextBlock,_levelLabel.text,_scoreLabel.text,_rowLabel.text, gameName, dateNow, nil];
    
    //将当前游戏数组写入总的存档数组
    [_allGameArray insertObject:thisGameArray atIndex:0];
    
    //如果超出5个存档，删掉最早期的一个
    if (_allGameArray.count >5) {
        [_allGameArray removeLastObject];
    }
    
    //将总存档数组归档
    BOOL rect = [NSKeyedArchiver archiveRootObject:_allGameArray toFile:path];
    if (!rect) {
        NSLog(@"游戏存档失败");
        return false;
    }
    return true;
}

#pragma -mark 存档页面初始化

//初始化保存游戏进度 填写进度名称页面
-(void)initSaveGameView
{
    int width = VIEW_W * 0.6;
    int height = VIEW_H * 0.3;
    int textH = height/3;
    
    _saveGameView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, VIEW_W, VIEW_H)];
    [_saveGameView setUserInteractionEnabled:YES];
    [_saveGameView setBackgroundColor:[UIColor blackColor]];
    
    
    UIImageView * centerView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    centerView.center = _saveGameView.center;
    [centerView setBackgroundColor:[UIColor blackColor]];
    [centerView setUserInteractionEnabled:YES];
    
    [_saveGameView addSubview:centerView];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, textH)];
    [label setText:@"存档名称"];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    
    _gameNameField = [[UITextField alloc]initWithFrame:CGRectMake(0, height/3, width, textH)];
    [_gameNameField setBackgroundColor:[UIColor lightGrayColor]];
    [_gameNameField setTextColor:[UIColor blackColor]];
    [_gameNameField setTextAlignment:NSTextAlignmentCenter];
    
    UIButton * saveGameNameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveGameNameBtn setTitle:@"确定" forState:UIControlStateNormal];
    [saveGameNameBtn setFrame:CGRectMake(0, height*2/3, width/2, textH)];
    [saveGameNameBtn addTarget:self action:@selector(saveGameNameBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    UIButton * saveGameNameCancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveGameNameCancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [saveGameNameCancelBtn setFrame:CGRectMake(width/2, height*2/3, width/2, textH)];
    [saveGameNameCancelBtn addTarget:self action:@selector(saveGameNameCancelBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [centerView addSubview:label];
    [centerView addSubview:_gameNameField];
    [centerView addSubview:saveGameNameBtn];
    [centerView addSubview:saveGameNameCancelBtn];
    
    [_saveGameView setHidden:YES];
}

#pragma -mark 主界面初始化

//初始化游戏主界面各种按钮以及文本显示
-(void)initButtons
{
    //暂停按钮
    UIButton * stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    int leftM = _boardImageView.frame.size.width + _boardImageView.frame.origin.x;
    int topM = _boardImageView.frame.origin.y;
    
    [stopBtn setFrame:CGRectMake(leftM+MARGIN_H, topM+10, LABELW, LABELH)];
    
    [stopBtn setBackgroundColor:[UIColor darkGrayColor]];
    [stopBtn addTarget:self action:@selector(stopBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [stopBtn setTitle:@"暂停" forState:UIControlStateNormal];
    [_backgroundView addSubview:stopBtn];
    
    //最高得分
    UIImageView * topScoreView = [[UIImageView alloc]initWithFrame:CGRectMake(leftM+MARGIN_H, topM+LABELH*3+MARGIN_V*3, LABELW, LABELH)];
    UILabel * topTmp = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, LABELW, LABELH)];
    [topTmp setText:@"最高得分"];
    [topTmp setTextColor:[UIColor blackColor]];
    [topTmp setFont:[UIFont fontWithName:@"Helvetica" size:FONT_SIZE]];
    [topTmp setTextAlignment:NSTextAlignmentCenter];
    [topScoreView addSubview:topTmp];
    [_backgroundView addSubview:topScoreView];
    
    UIImageView * topLabelView = [[UIImageView alloc]initWithFrame:CGRectMake(leftM+MARGIN_H, topM+LABELH*4+MARGIN_V*3.5, LABELW, LABELH)];
    _topLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, LABELW, LABELH)];
    [_topLabel setBackgroundColor:[UIColor darkGrayColor]];
    [_topLabel setFont:[UIFont fontWithName:@"Helvetica" size:FONT_SIZE]];
    [_topLabel setTextColor:[UIColor whiteColor]];
    [_topLabel setText:[NSString stringWithFormat:@"%lu",(long)_topScore]];
    [_topLabel setTextAlignment:NSTextAlignmentCenter];
    [topLabelView addSubview:_topLabel];
    [_backgroundView addSubview:topLabelView];
    
    //等级
    UIImageView * levelView = [[UIImageView alloc]initWithFrame:CGRectMake(leftM+MARGIN_H, topM+LABELH*5+MARGIN_V*4.5, LABELW, LABELH)];
    UILabel * levelTmp = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, LABELW, LABELH)];
    [levelTmp setText:@"等级"];
    [levelTmp setTextColor:[UIColor blackColor]];
    [levelTmp setFont:[UIFont fontWithName:@"Helvetica" size:FONT_SIZE]];
    [levelTmp setTextAlignment:NSTextAlignmentCenter];
    [levelView addSubview:levelTmp];
    [_backgroundView addSubview:levelView];
    
    UIImageView * levelLabelView = [[UIImageView alloc]initWithFrame:CGRectMake(leftM+MARGIN_H, topM+LABELH*6+MARGIN_V*5, LABELW, LABELH)];
    _levelLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, LABELW, LABELH)];
    [_levelLabel setBackgroundColor:[UIColor darkGrayColor]];
    [_levelLabel setFont:[UIFont fontWithName:@"Helvetica" size:FONT_SIZE]];
    [_levelLabel setTextColor:[UIColor whiteColor]];
    [_levelLabel setText:[NSString stringWithFormat:@"%lu",(long)_level]];
    [_levelLabel setTextAlignment:NSTextAlignmentCenter];
    [levelLabelView addSubview:_levelLabel];
    [_backgroundView addSubview:levelLabelView];
    
    //得分
    UIImageView * scoreView = [[UIImageView alloc]initWithFrame:CGRectMake(leftM+MARGIN_H, topM+LABELH*7+MARGIN_V*6, LABELW, LABELH)];
    UILabel * scoreTmp = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, LABELW, LABELH)];
    [scoreTmp setText:@"得分"];
    [scoreTmp setTextColor:[UIColor blackColor]];
    [scoreTmp setFont:[UIFont fontWithName:@"Helvetica" size:FONT_SIZE]];
    [scoreTmp setTextAlignment:NSTextAlignmentCenter];
    [scoreView addSubview:scoreTmp];
    [_backgroundView addSubview:scoreView];
    
    UIImageView * scoreLabelView = [[UIImageView alloc]initWithFrame:CGRectMake(leftM+MARGIN_H, topM+LABELH*8+MARGIN_V*6.5, LABELW, LABELH)];
    _scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, LABELW, LABELH)];
    [_scoreLabel setBackgroundColor:[UIColor darkGrayColor]];
    [_scoreLabel setFont:[UIFont fontWithName:@"Helvetica" size:FONT_SIZE]];
    [_scoreLabel setTextColor:[UIColor whiteColor]];
    [_scoreLabel setText:[NSString stringWithFormat:@"%lu",(long)_score]];
    [_scoreLabel setTextAlignment:NSTextAlignmentCenter];
    [scoreLabelView addSubview:_scoreLabel];
    [_backgroundView addSubview:scoreLabelView];
    
    //行数
    UIImageView * rowView = [[UIImageView alloc]initWithFrame:CGRectMake(leftM+MARGIN_H, topM+LABELH*9+MARGIN_V*7.5, LABELW, LABELH)];
    UILabel * rowTmp = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, LABELW, LABELH)];
    [rowTmp setText:@"行数"];
    [rowTmp setTextColor:[UIColor blackColor]];
    [rowTmp setFont:[UIFont fontWithName:@"Helvetica" size:FONT_SIZE]];
    [rowTmp setTextAlignment:NSTextAlignmentCenter];
    [rowView addSubview:rowTmp];
    [_backgroundView addSubview:rowView];
    
    UIImageView * rowLabelView = [[UIImageView alloc]initWithFrame:CGRectMake(leftM+MARGIN_H, topM+LABELH*10+MARGIN_V*8, LABELW, LABELH)];
    _rowLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, LABELW, LABELH)];
    [_rowLabel setBackgroundColor:[UIColor darkGrayColor]];
    [_rowLabel setFont:[UIFont fontWithName:@"Helvetica" size:FONT_SIZE]];
    [_rowLabel setTextColor:[UIColor whiteColor]];
    [_rowLabel setText:[NSString stringWithFormat:@"%lu",(long)_rows]];
    [_rowLabel setTextAlignment:NSTextAlignmentCenter];
    [rowLabelView addSubview:_rowLabel];
    [_backgroundView addSubview:rowLabelView];
    
    //按钮
    //向左
    _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_leftBtn setFrame:CGRectMake(MARGIN_LEFT, VIEW_H-MARGIN_DOWN-BUTTON_W_H, BUTTON_W_H, BUTTON_W_H)];
//    [_leftBtn addTarget:self action:@selector(leftBtnTapped) forControlEvents:UIControlEventTouchDown];
    [_leftBtn setTitle:@"左" forState:UIControlStateNormal];
    [_leftBtn setBackgroundColor:[UIColor darkGrayColor]];
    
    
    
//    UILongPressGestureRecognizer * lLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(leftLongPressed:)];
//    lLongPress.minimumPressDuration = 0.2;
//    [_leftBtn addGestureRecognizer:lLongPress];
    
    [_backgroundView addSubview:_leftBtn];
    //向下
    _downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_downBtn setFrame:CGRectMake(MARGIN_LEFT+BUTTON_W_H, VIEW_H-MARGIN_DOWN, BUTTON_W_H, BUTTON_W_H)];
//    [_downBtn addTarget:self action:@selector(downBtnTapped:) forControlEvents:UIControlEventTouchDown];
    [_downBtn setTitle:@"下" forState:UIControlStateNormal];
    [_downBtn setBackgroundColor:[UIColor darkGrayColor]];
    [_backgroundView addSubview:_downBtn];
    
    
//    UILongPressGestureRecognizer * dLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(downLongPressed:)];
//    dLongPress.minimumPressDuration = 0.2;
//    [_downBtn addGestureRecognizer:dLongPress];
    
    //向右
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightBtn setFrame:CGRectMake(MARGIN_LEFT+BUTTON_W_H*2, VIEW_H-MARGIN_DOWN-BUTTON_W_H, BUTTON_W_H, BUTTON_W_H)];
//    [_rightBtn addTarget:self action:@selector(rightBtnTapped) forControlEvents:UIControlEventTouchDown];
    [_rightBtn setTitle:@"右" forState:UIControlStateNormal];
    [_rightBtn setBackgroundColor:[UIColor darkGrayColor]];
    [_backgroundView addSubview:_rightBtn];
//    UILongPressGestureRecognizer * rLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(rightLongPressed:)];
//    rLongPress.minimumPressDuration = 0.2;
//    [_rightBtn addGestureRecognizer:rLongPress];
    
    [_leftBtn setUserInteractionEnabled:NO];
    [_rightBtn setUserInteractionEnabled:NO];
    [_downBtn setUserInteractionEnabled:NO];
    
    //逆时针旋转
    UIButton * rotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rotateBtn setFrame:CGRectMake(VIEW_W*0.7, VIEW_H*0.8, BUTTON_W_H*2, BUTTON_W_H*2)];
    [rotateBtn addTarget:self action:@selector(rotateBtnTapped) forControlEvents:UIControlEventTouchDown];
    [rotateBtn setTitle:@"转" forState:UIControlStateNormal];
    rotateBtn.layer.cornerRadius = BUTTON_W_H;
    [rotateBtn setBackgroundColor:[UIColor darkGrayColor]];
    [_backgroundView addSubview:rotateBtn];
    UILongPressGestureRecognizer * roLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(rotateLongPressed:)];
    roLongPress.minimumPressDuration = 0.2;
    
    [rotateBtn addGestureRecognizer:roLongPress];
    
}

//初始化Board面板的数组
-(void)initBoardArray
{
    _board = [[Board alloc]init];
    _boardArray = [[NSMutableArray alloc]init];
    for (int i=0; i<ROW; i++) {
        NSMutableArray * temp = [[NSMutableArray alloc]init];
        for (int j=0; j<COLUMN; j++) {
            UIImageView * view = [[UIImageView alloc]init];
            [view setFrame:CGRectMake(j*BLOCK_W_H, i*BLOCK_W_H, BLOCK_W_H, BLOCK_W_H)];
            int color = [[_board square][i+1][j+1] intValue];
            [self setImage:view withColor:color];
            
            [temp addObject:view];
            [_boardImageView addSubview:view];
        }
        [_boardArray addObject:temp];
    }
}

//给传入的UIImageView，根据color的值 setImage
-(void)setImage:(UIImageView *)imageView withColor:(NSInteger)color
{
    switch (color) {
        case 0://无色
            [imageView setImage:[UIImage imageNamed:@"null"]];
            break;
        case 1://红色
            [imageView setImage:[UIImage imageNamed:@"RedBlock"]];
            break;
        case 2://黄色
            [imageView setImage:[UIImage imageNamed:@"YellowBlock"]];
            break;
        case 3://绿色
            [imageView setImage:[UIImage imageNamed:@"GreenBlock"]];
            break;
        case 4://蓝色
            [imageView setImage:[UIImage imageNamed:@"BlueBlock"]];
            break;
        default:
            break;
    }
}

//初始化_liveImageArray 和 _nextImageArray
-(void)initLiveAndNextImageArray
{
    _liveImageArray = [[NSMutableArray alloc]init];
    _nextImageArray = [[NSMutableArray alloc]init];
    for (int i=0; i<4; i++) {
        UIImageView * imageView = [[UIImageView alloc]init];
        [self setImage:imageView withColor:[[_liveBlock color]intValue]];
        [_liveImageArray addObject:imageView];
        [_boardImageView addSubview:imageView];
        UIImageView * nextImageView = [[UIImageView alloc]init];
        [self setImage:nextImageView withColor:[[_nextBlock color]intValue]];
        [_nextImageArray addObject:nextImageView];
        [_backgroundView addSubview:nextImageView];
    }
}

-(void)setBlocksColor
{
    for (int i=0;i<4;i++) {
        [self setImage:_liveImageArray[i] withColor:_liveBlock.color.intValue];
        [self setImage:_nextImageArray[i] withColor:_nextBlock.color.intValue];
    }
}

-(void)newBlocks
{
    _liveBlock = _nextBlock;
    //随机产生一种方块
    int nextType = arc4random()%7;
    
    switch (nextType) {
        case I_TYPE:
            _nextBlock = [[IType alloc]init];
            break;
        case S_TYPE:
            _nextBlock = [[SType alloc]init];
            break;
        case Z_TYPE:
            _nextBlock = [[ZType alloc]init];
            break;
        case J_TYPE:
            _nextBlock = [[JType alloc]init];
            break;
        case L_TYPE:
            _nextBlock = [[LType alloc]init];
            break;
        case O_TYPE:
            _nextBlock = [[OType alloc]init];
            break;
        case T_TYPE:
            _nextBlock = [[TType alloc]init];
            break;
        default:
            break;
    }
    
    if (_liveBlock == nil) {
        int type = arc4random()%7;
        switch (type) {
            case I_TYPE:
                _liveBlock = [[IType alloc]init];
                break;
            case S_TYPE:
                _liveBlock = [[SType alloc]init];
                break;
            case Z_TYPE:
                _liveBlock = [[ZType alloc]init];
                break;
            case J_TYPE:
                _liveBlock = [[JType alloc]init];
                break;
            case L_TYPE:
                _liveBlock = [[LType alloc]init];
                break;
            case O_TYPE:
                _liveBlock = [[OType alloc]init];
                break;
            case T_TYPE:
                _liveBlock = [[TType alloc]init];
                break;
            default:
                break;
        }
    }
    [self setBlocksColor];
}

//背景音乐
// 初始化音乐播放器
- (AVAudioPlayer *)loadMusic
{
    // 1 初始化播放器需要指定音乐文件的路径
    NSString *path = [[NSBundle mainBundle]pathForResource:@"FC精选合集-俄罗斯方块音乐集" ofType:@"mp3"];
    // 2 将路径字符串转换成url，从本地读取文件，需要使用fileURL
    NSURL *url = [NSURL fileURLWithPath:path];
    // 3 初始化音频播放器
    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    // 4 设置循环播放
    // 设置循环播放的次数
    // 循环次数=0，声音会播放一次
    // 循环次数=1，声音会播放2次
    // 循环次数小于0，会无限循环播放
    [player setNumberOfLoops:-1];
    
    // 5 准备播放
    [player prepareToPlay];
    
    return player;
}


//状态栏隐藏
-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
