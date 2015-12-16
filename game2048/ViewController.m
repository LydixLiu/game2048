//
//  ViewController.m
//  game2048
//
//  Created by Lydix-Liu on 15/12/16.
//  Copyright © 2015年 某隻. All rights reserved.
//


typedef unsigned long long U64;
typedef signed long long S64;
typedef unsigned int U32;
typedef signed int S32;
typedef unsigned short U16;
typedef signed short S16;
typedef unsigned char U8;
typedef signed char S8;


#define ROW 7
#define kTabBar_Height  49
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import "UIColor+Hex.h"

@interface ViewController () {
    U64 _expAll;
}

@property (nonatomic, strong) NSMutableArray *cards;///< 游戏数据显示

#pragma 懒加载
@property (nonatomic, strong) UIView *gameView;///< 游戏区域
@property (nonatomic, strong) UILabel *labelExp;///< 经验条显示
@property (nonatomic, strong) CALayer *layerExp;///< 当前经验显示

@property (nonatomic, strong) UIView *toolBar;///< 自定义工具栏

@property (nonatomic, assign) CGPoint startP;/// 手指接触屏幕时的左边
@property (nonatomic, assign) CGPoint endP;/// 手指离开屏幕时的左边

@property (nonatomic, assign) U64 expAll;///< 升级经验
@property (nonatomic, assign) U64 expCurrent;///< 当前经验
@property (nonatomic, assign) U32 crtLevel;///< 当前等级

@property (nonatomic, assign) U8 hardLevel;///< 难度等级

/* 以下是测试代码所需 */
@property (nonatomic, assign) U32 step;///< 移动步数
@property (nonatomic, strong) NSTimer *timer;///<

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupData];
}

- (void)setup {
    self.view.backgroundColor = [UIColor colorWithARGBString:@"#77c8f0"];
    self.hardLevel = 1;
    
    [self toolBar];
    [self gameView];
}

/**
 *  初始化cards
 */
- (void)setupData {
    self.step = 0;
    self.crtLevel = 0;
    self.cards = [NSMutableArray array];
    
    for (int i = 0; i < ROW; i++) {
        NSMutableArray *arr = [NSMutableArray array];
        for (int j = 0 ; j < ROW; j++) {
            ANYCardPuzzle *card = [ANYCardPuzzle cardWithLocation:CGPointMake(i, j)];
            card.width = self.gameView.bounds.size.width / ROW;
            card.hardLevel = self.hardLevel;
            [self.gameView addSubview:card.viewShow];
            [arr addObject:card];
        }
        [self.cards addObject:arr];
    }
    
    [self addCard];
    [self addCard];
}

/**
 *  重新开始
 */
- (void)restartGame {
    
    [_gameView removeFromSuperview];
    _gameView = nil;
    
    [self setupData];
}

#pragma mark - 各种懒加载视图
/**
 *  自定义工具栏
 *
 */
- (UIView *)toolBar {
    
    if (!_toolBar) {
        
        _toolBar  = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - kTabBar_Height, SCREEN_WIDTH, kTabBar_Height)];
        _toolBar.backgroundColor = [UIColor colorWithARGBString:@"#EEEEEE"];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 4.5, 40, 40)];
        [button setImage:[UIImage imageNamed:@"ic_tank_back"] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [_toolBar addSubview:button];
        
        
        UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 4.5, 40, 40)];
        button1.titleLabel.font = [UIFont systemFontOfSize:15];
        [button1 setImage:[UIImage imageNamed:@"ic_chat_video_play"] forState:UIControlStateNormal];
        [button1 addTarget:self action:@selector(startTimer) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar addSubview:button1];
        
        [self.view addSubview:_toolBar];
    }
    
    return _toolBar;
}

/**
 * 懒加载游戏视图
 */
- (UIView *)gameView {
    if (_gameView == nil) {
        
        CGFloat x = self.hardLevel == 0 ? 0 : 15;
        CGFloat w = (self.view.bounds.size.width - x * 2)/1.3;
        x = (self.view.bounds.size.width - w) / 2.;
        CGFloat h = w;
        CGFloat y = (self.view.bounds.size.height - w) / 2;
        _gameView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        [self.view addSubview:_gameView];
        
        if (self.hardLevel > 0) {
            CGAffineTransform at = CGAffineTransformMakeRotation(M_PI/4);
            [_gameView setTransform:at];
        }
    }
    return _gameView;
}

/**
 *  经验条显示
 *
 */
- (UILabel *)labelExp {
    
    if (!_labelExp) {
        _labelExp = [[UILabel alloc] initWithFrame:CGRectMake(60, SCREEN_HEIGHT - kTabBar_Height - 40, SCREEN_WIDTH - 120, 20)];
        _labelExp.backgroundColor = [UIColor colorWithARGBString:@"#16a8ef"];
        
        _labelExp.layer.cornerRadius = 10;
        _labelExp.layer.masksToBounds = YES;
        
        UILabel *labelShow = [[UILabel alloc] initWithFrame:_labelExp.bounds];
        labelShow.textAlignment = NSTextAlignmentCenter;
        labelShow.textColor = [UIColor colorWithARGBString:@"#333333"];
        labelShow.font = [UIFont systemFontOfSize:13];
        [_labelExp addSubview:labelShow];
        
        [self.view addSubview:_labelExp];
    }
    
    return _labelExp;
}

/**
 *  当前经验值显示
 *
 */
- (CALayer *)layerExp {
    
    if (!_layerExp) {
        _layerExp = [CALayer layer];
        _layerExp.frame = CGRectMake(0, 0, 0, 20);
        _layerExp.backgroundColor = [UIColor whiteColor].CGColor;
        _layerExp.cornerRadius = 10;
        _layerExp.masksToBounds = YES;
        
        [_labelExp.layer insertSublayer:_layerExp atIndex:0];
    }
    
    return _layerExp;
}

/**
 *  向游戏视图添加一张新牌
 */
- (void)addCard {
    int x = arc4random_uniform(ROW);
    int y = arc4random_uniform(ROW);
    
    ANYCardPuzzle *card = [[self.cards objectAtIndex:x] objectAtIndex:y];
    if (card.status != 0) {
        if (![self isFull])
            [self addCard];
    } else {
        card.scroe = 2;
        /*
         int num = arc4random_uniform(100);
         if (num < 90) {
         num = 2;
         card.scroe = 2;
         }else
         {
         card.scroe = 4;
         num = 4;
         }*/
    }
}

#pragma mark - 数量变化控制
- (U64)expAll {
    _expAll = [self getUpLevelStandard:self.crtLevel];
    return _expAll;
}

- (void)setExpAll:(U64)expAll {
    _expAll = expAll;
    
    ((UILabel *)self.labelExp.subviews[0]).text = [NSString stringWithFormat:@"%lld/%lld", self.expCurrent, self.expAll];
}

- (void)setExpCurrent:(U64)expCurrent {
    _expCurrent = expCurrent;
    
    ((UILabel *)self.labelExp.subviews[0]).text = [NSString stringWithFormat:@"%lld/%lld", self.expCurrent, self.expAll];
    self.layerExp.frame = CGRectMake(0, 0, (SCREEN_WIDTH-120) / self.expAll * expCurrent, 20);
}

- (void)setCrtLevel:(U32)crtLevel {
    _crtLevel = crtLevel;
    
    self.expAll = [self getUpLevelStandard:crtLevel];
    self.expCurrent = 0;
}

#pragma mark - 移动
// 记录下接触屏幕时的位置
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        self.startP = [touch locationInView:self.view];
    }
}

/**
 * 该方法可得到离开屏幕时的位置,并且根据开始时的位置判断划的方向
 */
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        self.endP = [touch locationInView:self.view];
    }
    
    CGFloat moveX = self.endP.x - self.startP.x;
    CGFloat moveY = self.endP.y - self.startP.y;
    CGPoint moveCount = CGPointZero;
    
    if (fabs(moveX) > 5 && fabs(moveY) > 5) {
        
        if (moveX < 0 && moveY < 0) {
            moveCount = [self moveLeft];
        } else if (moveX < 0 && moveY > 0) {
            moveCount = [self moveBottom];
        } else if (moveX > 0 && moveY > 0) {
            moveCount = [self moveRight];
        } else {
            moveCount = [self moveTop];
        }
        
        if (![self isFull] && !CGPointEqualToPoint(moveCount, CGPointZero)) {
            [self addCard];
        } else if ([self isFull]) {
            if ([self isGameOver]) {
                NSLog(@"\n*************************\n******* Game Over *******\n*************************\n");
            }
        }
    }
}

- (CGPoint)moveTop {
    U32 moveCount = 0;//移动数量
    U32 combineCount = 0;//合并数量
    for (int j = 0; j < ROW; j++) {
        for (int i = 0; i < ROW - 1; i++) {
            for (int k = i + 1; k < ROW; k++) {
                ANYCardPuzzle *cardTop = self.cards[i][j];
                ANYCardPuzzle *cardBottom = self.cards[k][j];
                
                if (cardBottom.status == 1) {
                    if (cardTop.status == 0) {
                        [self moveCard:cardBottom toCard:cardTop];
                        moveCount ++;
                    } else if (cardTop.scroe == cardBottom.scroe) {
                        [self moveCard:cardBottom toCard:cardTop];
                        i++;//防止重复合并，跳过已合并项，如2,2,4变成8
                        combineCount ++;
                    }
                }
                
                if (cardTop.status == -1 ||
                    cardBottom.status != 0) {
                    break;
                }
            }
        }
    }
    
    return CGPointMake(moveCount, combineCount);
}

- (CGPoint)moveLeft {
    U32 moveCount = 0;//移动数量
    U32 combineCount = 0;//合并数量
    for (int i = 0; i < ROW; i++) {
        for (int j = 0; j < ROW - 1; j++) {
            for (int k = j + 1; k < ROW; k++) {
                ANYCardPuzzle *cardLeft = self.cards[i][j];
                ANYCardPuzzle *cardRight = self.cards[i][k];
                
                if (cardRight.status == 1) {
                    if (cardLeft.status == 0) {
                        [self moveCard:cardRight toCard:cardLeft];
                        moveCount ++;
                    } else if (cardLeft.scroe == cardRight.scroe) {
                        [self moveCard:cardRight toCard:cardLeft];
                        j++;
                        combineCount ++;
                    }
                }
                
                if (cardLeft.status == -1 ||
                    cardRight.status != 0) {
                    break;
                }
            }
        }
    }
    return CGPointMake(moveCount, combineCount);
}

- (CGPoint)moveBottom {
    U32 moveCount = 0;//移动数量
    U32 combineCount = 0;//合并数量
    for (int j = 0; j < ROW; j++) {
        for (int i = 0; i < ROW - 1; i++) {
            for (int k = i + 1; k < ROW; k++) {
                ANYCardPuzzle *cardTop = self.cards[ROW - 1 - k][j];
                ANYCardPuzzle *cardBottom = self.cards[ROW - 1 - i][j];
                
                if (cardTop.status == 1) {
                    if (cardBottom.status == 0) {
                        [self moveCard:cardTop toCard:cardBottom];
                        moveCount ++;
                    } else if (cardBottom.scroe == cardTop.scroe) {
                        [self moveCard:cardTop toCard:cardBottom];
                        i++;
                        combineCount ++;
                    }
                }
                
                if (cardBottom.status == -1 ||
                    cardTop.status != 0) {
                    break;
                }
            }
        }
    }
    return CGPointMake(moveCount, combineCount);
}

- (CGPoint)moveRight {
    U32 moveCount = 0;//移动数量
    U32 combineCount = 0;//合并数量
    for (int i = 0; i < ROW; i++) {
        for (int j = 0; j < ROW - 1; j++) {
            for (int k = j + 1; k < ROW; k++) {
                ANYCardPuzzle *cardRight = self.cards[i][ROW - 1 - j];
                ANYCardPuzzle *cardLeft = self.cards[i][ROW - 1 - k];
                
                if (cardLeft.status == 1) {
                    if (cardRight.status == 0) {
                        [self moveCard:cardLeft toCard:cardRight];
                        moveCount ++;
                    } else if (cardLeft.scroe == cardRight.scroe) {
                        [self moveCard:cardLeft toCard:cardRight];
                        j++;
                        combineCount ++;
                    }
                }
                
                if (cardRight.status == -1 ||
                    cardLeft.status != 0) {
                    break;
                }
            }
        }
    }
    return CGPointMake(moveCount, combineCount);
}

- (void)moveCard:(ANYCardPuzzle *)card1 toCard:(ANYCardPuzzle *)card2 {
    card2.scroe += card1.scroe;
    card1.scroe = 0;
    
    [self changeScore:card2.scroe];
}

#pragma mark - 其它
/**
 *  计算card可移动方向
 *
 *  @param card 需要计算的card
 *
 *  @return 可移动方向
 */
- (ANYPuzzleSwapDirection)directionOfCard:(ANYCardPuzzle *)card {
    ANYPuzzleSwapDirection direction = ANYPuzzleSwapDirectionNone;
    
    if (card.status == -1) {
        card.directions = direction;
        return direction;
    }
    
    ANYCardPuzzle *cardTop = [self getCard:card.location.x - 1 y:card.location.y];
    if (cardTop) {
        if (card.scroe == cardTop.scroe && card.scroe > 0) {//和上面相等
            direction |= ANYPuzzleSwapDirectionTop;
        } else if (cardTop.status == 0 && card.status == 1) {
            direction |= ANYPuzzleSwapDirectionTop;
        }
    }
    
    ANYCardPuzzle *cardLeft = [self getCard:card.location.x y:card.location.y - 1];
    if (cardLeft) {
        if (card.scroe == cardLeft.scroe && card.scroe > 0) {//和左边相等
            direction |= ANYPuzzleSwapDirectionLeft;
        } else if (cardLeft.status == 0 && card.status == 1) {
            direction |= ANYPuzzleSwapDirectionLeft;
        }
    }
    
    ANYCardPuzzle *cardBottom = [self getCard:card.location.x + 1 y:card.location.y];
    if (cardBottom) {
        if (cardBottom.scroe == card.scroe && card.scroe > 0) {//和下面相等
            direction |= ANYPuzzleSwapDirectionBottom;
        } else if (cardBottom.status == 0 && card.status == 1) {
            direction |= ANYPuzzleSwapDirectionBottom;
        }
    }
    
    ANYCardPuzzle *cardRight = [self getCard:card.location.x y:card.location.y + 1];
    if (cardRight) {
        if (card.scroe == cardRight.scroe && card.scroe > 0) {//和左边相等
            direction |= ANYPuzzleSwapDirectionRight;
        } else if (cardRight.status == 0 && card.status == 1) {
            direction |= ANYPuzzleSwapDirectionRight;
        }
    }
    
    card.directions = direction;
    
    return direction;
}

/**
 *  判断当前游戏界面是否已填充满
 *
 *  @return 已填满:YES
 */
- (BOOL)isFull {
    for (int i = 0; i < ROW; i++) {
        for (int j = 0; j < ROW; j++) {
            ANYCardPuzzle *card = self.cards[i][j];
            if (card.status == 0) {
                return NO;
            }
        }
    }
    return YES;
}

/**
 *  游戏是否结束
 *
 *  @return 结束:YES
 */
- (BOOL)isGameOver {
    
    for (int i = 0; i < ROW; i++) {
        for (int j = 0; j < ROW; j++) {
            ANYCardPuzzle *card = self.cards[i][j];
            if ([self directionOfCard:card] != ANYPuzzleSwapDirectionNone) {
                return NO;
            }
        }
    }
    
    return YES;
}

/**
 *  获取指定位置的card
 *
 *  @param x
 *  @param y
 *
 *  @return 指定位置的card,若位置有误,返回nil
 */
- (ANYCardPuzzle *)getCard:(int)x y:(int)y {
    if (x < 0 ||
        y < 0 ||
        x >= ROW ||
        y >= ROW) {
        return nil;
    } else {
        return self.cards[x][y];
    }
}

/**
 * 更改分数
 */
- (void)changeScore:(int)score {
    if ([self getUpLevelStandard:self.crtLevel] < self.expCurrent + score) {
        score -= self.expAll - self.expCurrent;
        self.crtLevel ++;
        self.expCurrent += score;
        
    } else {
        self.expCurrent += score;
    }
    
}

/**
 *  升级规则
 */
- (U64)getUpLevelStandard:(U32)iLevel {
    long long lUpLevelWeight = 0;
    
    if(iLevel <= 8)
        lUpLevelWeight = pow(2, iLevel+1);
    else if(iLevel < 100)
        lUpLevelWeight = pow(2,(iLevel - 1)/4 + 7) + ((iLevel - 1)%4 + 1) * pow(2,(iLevel - 1)/4 + 5);
    else if(iLevel >= 100)
        lUpLevelWeight = pow(2,(99 - 1)/4 + 7) + ((99 - 1)%4 + 1) * pow(2,(99 - 1)/4 + 5);
    lUpLevelWeight *= 1000;
    
    return  lUpLevelWeight;
}

- (U32)getLevelWithFish:(U64)fish {
    
    U32 level = 0;
    
    while (1) {
        U64 fishCount = [self getUpLevelStandard:level];
        if (fishCount > self.expAll)
            return level;
        
        level++;
    }
}

/**
 *  判断能否向某方向移动
 */
- (BOOL)canMoveToDirctions:(ANYPuzzleSwapDirection)dirctions {
    
    for (int i = 0; i < ROW; i++) {
        for (int j = 0; j < ROW; j++) {
            ANYPuzzleSwapDirection direction = ANYPuzzleSwapDirectionNone;
            ANYCardPuzzle *card = self.cards[i][j];
            direction |= [self directionOfCard:card];
            if (direction & dirctions) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - 以下是测试代码
- (void)startTimer {
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(autoPlay) userInfo:nil repeats:YES];
    } else {
        self.step = 0;
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)autoPlay {
    CGPoint moveCount = CGPointZero;
    
    if ([self canMoveToDirctions:ANYPuzzleSwapDirectionLeft | ANYPuzzleSwapDirectionTop]) {
        if (self.step % 2 == 0) {
            moveCount = [self moveLeft];
        } else {
            moveCount = [self moveTop];
        }
    } else {
        if ([self canMoveToDirctions:ANYPuzzleSwapDirectionBottom]) {
            moveCount = [self moveBottom];
            if (self.step % 2 != 0) {
                self.step ++;
            }
        } else {
            moveCount = [self moveRight];
            if (self.step % 2 != 1) {
                self.step ++;
            }
        }
    }
    
    if (![self isFull] && !CGPointEqualToPoint(moveCount, CGPointZero)) {
        [self addCard];
    }
    if ([self isFull]) {
        
        if ([self isGameOver]) {
            [self.timer invalidate];
            self.timer = nil;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"重新开始" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self restartGame];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            
        }
    }
    self.step ++;
}

@end




@implementation ANYCardPuzzle

+ (ANYCardPuzzle *)cardWithLocation:(CGPoint)location {
    ANYCardPuzzle *card = [[ANYCardPuzzle alloc] init];
    card.location = location;
    card.status = 0;
    return card;
}

- (UIImageView *)viewShow {
    if (self.status == -1)
        return nil;
    
    if (!_viewShow) {
        _viewShow = [[UIImageView alloc] initWithFrame:CGRectMake(self.location.y * self.width + 2, self.location.x * self.width + 2, self.width - 4, self.width - 4)];
        _viewShow.layer.cornerRadius = 5;
        _viewShow.layer.masksToBounds = YES;
        UILabel *label = [[UILabel alloc] initWithFrame:_viewShow.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%d%d",(int)self.location.x,(int)self.location.y];
//        [_viewShow addSubview:label];
        
        _viewShow.backgroundColor = [UIColor colorWithARGBString:@"#16a8ef"];
    }
    
    return _viewShow;
}

- (void)setScroe:(U32)scroe {
    if (self.status == -1)
        return;
    
    _scroe = scroe;
    _status = scroe > 0;
    
    if (scroe > 0) {
        self.viewShow.image = [UIImage imageNamed:[NSString stringWithFormat:@"tp%d", scroe]];
    } else {
        self.viewShow.image = nil;
    }
}

- (int)status {
    if (self.hardLevel == 0) {
        _status = self.scroe > 0;
        return _status;
    }
    
    int x = self.location.x;
    int y = self.location.y;
    
    int status = 0;
    
    switch (x) {
        case 0:
        {
            if (y == 6) {
                status = -1;
            }
        }
            break;
        case 1:
        case 2:
        case 3:
        {
            if (y > 4) {
                status = -1;
            }
        }
            break;
        case 4:
        {
            status = 0;
        }
            break;
        case 5:
        {
            if (!(y == 0 || y == 4)) {
                status = -1;
            }
        }
            break;
        case 6:
        {
            if (y != 4) {
                status = -1;
            }
        }
            break;
            
        default:
            break;
    }
    if (status != -1) {
        status = self.scroe > 0 ? 1 : 0;
    }
    _status = status;
    
    return _status;
}

@end