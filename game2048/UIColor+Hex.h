//
//  UIColor+Hex.h
//  game2048
//
//  Created by Lydix-Liu on 15/12/16.
//  Copyright © 2015年 某隻. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

/**
 *  获取16进制RGB值对应的颜色
 *
 *  @param rgbString 16进制RGB值 如@“#ffffff”
 *
 *  @return
 */
+ (UIColor *)colorWithARGBString:(NSString *)rgbString;

@end
