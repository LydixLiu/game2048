//
//  UIColor+Hex.m
//  game2048
//
//  Created by Lydix-Liu on 15/12/16.
//  Copyright © 2015年 某隻. All rights reserved.
//

#define DEFAULT_VOID_COLOR [UIColor whiteColor]

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorWithARGBString:(NSString *) stringToConvert alpha:(CGFloat)alpha{
    if(!stringToConvert || stringToConvert.length == 0)
        return DEFAULT_VOID_COLOR;
    
    stringToConvert = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];//字符串处理
    
    //例子，stringToConvert #ffffff
    if ([stringToConvert length] < 6){
        return DEFAULT_VOID_COLOR;//如果非十六进制，返回白色
    }
    if ([stringToConvert hasPrefix:@"#"])
        stringToConvert = [stringToConvert substringFromIndex:1];//去掉头
    if ([stringToConvert length] != 6)//去头非十六进制，返回白色
        return DEFAULT_VOID_COLOR;
    
    unsigned int r, g, b;
    //NSScanner把扫描出的制定的字符串转换成Int类型
    [[NSScanner scannerWithString:[stringToConvert substringWithRange:NSMakeRange(0, 2)]] scanHexInt:&r];
    [[NSScanner scannerWithString:[stringToConvert substringWithRange:NSMakeRange(2, 2)]] scanHexInt:&g];
    [[NSScanner scannerWithString:[stringToConvert substringWithRange:NSMakeRange(4, 2)]] scanHexInt:&b];
    //转换为UIColor
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:alpha];
}

+ (UIColor *)colorWithARGBString:(NSString *)rgbString {
    return [self colorWithARGBString:rgbString alpha:1.];
}

@end
