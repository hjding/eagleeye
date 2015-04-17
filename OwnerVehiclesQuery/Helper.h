//
//  Helper.h
//  CaiChao
//
//  Created by hjd on 13-12-25.
//  Copyright (c) 2013年 YangWusheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface Helper : NSObject

#pragma mark - 界面显示
//界面显示
+ (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message;
+ (void)showHintMessage:(NSString *)message;

#pragma mark - 图片操作
//图片操作
+ (UIImage *)getPNGImageWithName:(NSString *)name;
+ (UIImage *)createImageWithColor:(UIColor *)color andRect:(CGRect)rect;
+ (UIImage *)createImageWithView:(UIView *)view middleImage:(UIImage *)image andEdgeInset:(UIEdgeInsets)edgeInset;
+ (CGSize)resizeImageSize:(CGSize)imageSize andContainerWidth:(float)width;
/*
 10种颜色，首字符
 */
+ (void)setImageWithView:(UIView *)view number:(int)number textStr:(NSString *)textStr;
/*
 29个默认头像
 */
+ (UIImage *)getImageWithNumber:(int)number;

#pragma mark - 文本操作
//文本操作
+ (CGSize)getContentActualSize:(NSString *)str WithFont:(UIFont *)font; //单行
+ (CGSize)getContentActualSize:(NSString *)str withWidth:(float)width WithFont:(UIFont *)font; //多行
+ (CGSize)getAttributedStringHeightWithString:(NSAttributedString *)string  WidthValue:(int)width; //多行
+ (NSAttributedString *)getAttributedStingWithString:(NSString *)orginalStr minLineHeight:(float)lineHeight;

#pragma mark - 文件操作
//文件操作
+ (NSString *)createDirectoryWithName:(NSString *)directoryName;
+ (NSString *)documentPathForFileName:(NSString *)fileName;
+ (double)getFileSize:(NSString *)filePath;

#pragma mark - 程序版本
//程序版本
+ (NSDictionary *)getCurrentAppInfo;
+ (NSDictionary *)getCurrentDeviceInfo;

#pragma mark - 时间操作
//时间操作
+ (NSString *)getCurrentDate;
+ (NSString *)timeStringFileName;
+ (NSString *)timeStringForWeather;
+ (NSString *)timeStringSince1970;
+ (NSString *)timeStringWithDate:(NSDate *)date;
+ (NSDate *)dateWithString:(NSString *)dateStr;
+ (NSString *)timeBeforeWithDate:(NSDate *)date;
+ (NSString *)timeWithStamp:(NSString *)intervalString;
+ (NSString *)dateStrWithStamp:(NSString *)intervalString;
+ (NSString *)timeBeforeWithStamp:(NSString *)intervalString;

#pragma mark - 加密和编码
//加密和编码
+ (NSString *)hmacsha1:(NSString *)data secret:(NSString *)key;
+ (NSString *)createMD5:(NSString *)signString;
+ (NSString *)base64EncodedString:(NSString *)originStr;
+ (NSString *)base64DecodedString:(NSString *)encodedStr;
+ (NSString *)urlEncodedString:(NSString *)originStr;

#pragma mark - 数据操作
//数据操作
+ (id)jsonObjectWithString:(NSString *)originStr;
+ (NSString *)jsonStringWithObject:(id)object;
+ (NSString *)filteredString:(NSString *)originalStr; //过滤首尾空格和制表符

#pragma mark - 字符操作
+ (BOOL)isDigital:(NSString *)str;      //一个字符是不是数字
+ (BOOL)isLetter:(NSString *)str;       //一个字符是不是字母
+ (BOOL)isChinese:(NSString *)str;      //一个字符是不是汉字

#pragma mark - 字符串操作
+(NSString *)getSplitString:(NSString *)str With:(NSString *)c;    //用c分隔str
@end
