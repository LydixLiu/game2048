//
//  ViewController.h
//  game2048
//
//  Created by Lydix-Liu on 15/12/16.
//  Copyright © 2015年 某隻. All rights reserved.
//

typedef enum {
    ANYPuzzleSwapDirectionNone = 0,
    ANYPuzzleSwapDirectionTop = 1 << 0,
    ANYPuzzleSwapDirectionLeft = 1 << 1,
    ANYPuzzleSwapDirectionBottom = 1 << 2,
    ANYPuzzleSwapDirectionRight = 1 << 3,
    ANYPuzzleSwapDirectionAll = 15,
}ANYPuzzleSwapDirection;

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController


@end


/**
 *  拼鱼方块数据
 */
@interface ANYCardPuzzle : NSObject

@property (nonatomic, assign) CGPoint location;///< 所在方位

@property (nonatomic, assign) CGFloat width;///< 支持宽度

@property (nonatomic, assign) U8 hardLevel;///< 难度等级

@property (nonatomic, assign) int status;///< 状态是否可用 -1:不可用 0:可用但未使用 1:已使用

@property (nonatomic, assign) U32 scroe;///< 分数

@property (nonatomic, assign) ANYPuzzleSwapDirection directions;///< 可滑动方向

@property (nonatomic, strong) UIImageView *viewShow;///< 显示视图

/**
 *  初始化方法
 *
 *  @param location 所在位置
 *
 *  @return
 */
+ (ANYCardPuzzle *)cardWithLocation:(CGPoint)location;

@end