//
//  Helper.m
//  CaiChao
//
//  Created by YangWusheng on 13-12-25.
//  Copyright (c) 2013年 YangWusheng. All rights reserved.
//

#import "Helper.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

#define IOS7_OR_LATER           ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )

#define recourcesPath           [[NSBundle mainBundle] resourcePath]
#define kDeviceHeight           [UIScreen mainScreen].bounds.size.height
#define kDeviceWidth            [UIScreen mainScreen].bounds.size.width

#define Color(r,g,b,a)          [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/1.0]

@implementation Helper

#pragma mark - 界面显示
+ (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message
{
    NSString *tit = title;
    NSString *msg = message;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:tit message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
//    [alert release];
}

+ (void)showHintMessage:(NSString *)message
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.frame = window.frame;
    backgroundView.alpha = 0;
    backgroundView.backgroundColor = [UIColor clearColor];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(kDeviceWidth / 2.0 - 40, kDeviceHeight / 2.0 - 25, 80, 50)];
    textLabel.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    textLabel.layer.cornerRadius = 6;
    textLabel.clipsToBounds = YES;
    textLabel.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    textLabel.layer.shadowOffset = CGSizeMake(0, 5);
    textLabel.layer.shadowOpacity = 0.8;
    textLabel.layer.cornerRadius = 5;
    if (IOS8_OR_LATER)
        textLabel.text = [NSString stringWithFormat:@"%@\n", message];
    else
        textLabel.text = [NSString stringWithFormat:@"%@\n\n", message];
    textLabel.numberOfLines = 0;
    textLabel.font = [UIFont systemFontOfSize:13.0f];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    CGSize actualSize = [Helper getContentActualSize:textLabel.text WithFont:textLabel.font];
    textLabel.frame = CGRectMake(kDeviceWidth / 2.0 - (actualSize.width + 8.0) / 2.0, kDeviceHeight / 2.0 - 25, actualSize.width + 8, 50);
    [backgroundView addSubview:textLabel];
    UILabel *smile = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, textLabel.width, textLabel.height - 24)];
    smile.textAlignment = NSTextAlignmentCenter;
    smile.text = @"^_^";
    smile.textColor = [UIColor whiteColor];
    smile.font = textLabel.font;
    [textLabel addSubview:smile];
    [window addSubview:backgroundView];
    
    [UIView animateWithDuration:0.4 animations:^{
        backgroundView.alpha = 1;
    }];
  
    [backgroundView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}

#pragma mark - 图片操作
+ (UIImage *)getPNGImageWithName:(NSString *)name
{
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"png"]];
    return image;
}

+ (UIImage *)createImageWithColor:(UIColor *)color andRect:(CGRect)rect
{
    CGRect newRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    UIGraphicsBeginImageContext(newRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, newRect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

//10种颜色
+ (void)setImageWithView:(UIView *)view number:(int)number textStr:(NSString *)textStr
{
    int colorId = number % 10;
    UIColor *color = nil;
    switch (colorId)
    {
        case 0:
            color = Color(0, 170, 77, 1); //绿
            break;
        case 1:
            color = Color(234, 87, 42, 1); //砖红
            break;
        case 2:
            color = Color(60, 79, 160, 1); //深蓝
            break;
        case 3:
            color = Color(119, 84, 72, 1); //棕
            break;
        case 4:
            color = Color(109, 175, 46, 1); //黄绿
            break;
        case 5:
            color = Color(231, 52, 104, 1); //胭脂红
            break;
        case 6:
            color = Color(0, 143, 204, 1); //蓝
            break;
        case 7:
            color = Color(242, 147, 24, 1); //桔
            break;
        case 8:
            color = Color(8, 144, 130, 1); //深绿
            break;
        case 9:
            color = Color(133, 56, 144, 1); //紫
            break;
    }
    
    NSString *firstStr = [textStr substringToIndex:1];
    if ([Helper isLetter:firstStr])
        firstStr = [firstStr uppercaseString];
    else if (![Helper isChinese:firstStr])
        firstStr = @"Ω";
    
    UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
    label.text = firstStr;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:view.bounds.size.width / 2.0];
    label.textAlignment = NSTextAlignmentCenter;
    view.backgroundColor = color;
    [view addSubview:label];
    
//    [label.layer renderInContext:context];
}

/*
 29个默认头像
 */
+ (UIImage *)getImageWithNumber:(int)number
{
    UIImage *image = nil;
    int imageId = number % 29 + 1;
    NSString *imageName = [[NSString alloc] initWithFormat:@"avatar_%i", imageId];
    image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:@"png"]];
    
    return image;
}

+ (UIImage *)createImageWithView:(UIView *)view middleImage:(UIImage *)image andEdgeInset:(UIEdgeInsets)edgeInset
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(edgeInset.left, edgeInset.top, view.width - edgeInset.left - edgeInset.right, view.height - edgeInset.top - edgeInset.bottom)];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.image = image;
    [view addSubview:imageView];
    
    UIGraphicsBeginImageContext(view.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image1 = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [imageView removeFromSuperview];
    
    return image1;
}

+ (CGSize)resizeImageSize:(CGSize)imageSize andContainerWidth:(float)width
{
    CGSize size = imageSize;
    
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    if (imageWidth >= width || imageHeight >= width)
    {
        CGFloat scaleLength = imageHeight > imageWidth ? imageHeight : imageWidth;
        CGFloat scaleRatio = width / scaleLength;
        size = CGSizeMake(imageWidth * scaleRatio, imageHeight * scaleRatio);
    }
    
    return size;
}

#pragma mark - 文本操作
//单行
+ (CGSize)getContentActualSize:(NSString *)str WithFont:(UIFont *)font
{
    NSDictionary *attrDic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    
    CGSize actualSize = CGSizeZero;
    if (IOS7_OR_LATER)
        actualSize = [str sizeWithAttributes:attrDic];
    
    return actualSize;
}

//多行
+ (CGSize)getContentActualSize:(NSString *)str withWidth:(float)width WithFont:(UIFont *)font
{
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attrDic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, paraStyle, NSParagraphStyleAttributeName, nil];
    
    CGSize actualSize = CGSizeZero;
    if (IOS7_OR_LATER)
        actualSize = [str boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:attrDic context:nil].size;
    
    return actualSize;
}

//多行
+ (CGSize)getAttributedStringHeightWithString:(NSAttributedString *)string  WidthValue:(int)width
{
    int total_height = 0;
    int total_width = width;
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);    //string 为要计算高度的NSAttributedString
    CGRect drawingRect = CGRectMake(0, 0, width, 1000);  //这里的高要设置足够大
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
    CGPathRelease(path);
    CFRelease(framesetter);
    
    NSArray *linesArray = (NSArray *)CTFrameGetLines(textFrame);
    
    CGPoint origins[[linesArray count]];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    int line_y = (int) origins[[linesArray count] -1].y;  //最后一行line的原点y坐标
    
    CGFloat ascent;
    CGFloat descent;
    CGFloat leading;
    
    CTLineRef line = (__bridge CTLineRef) [linesArray objectAtIndex:[linesArray count]-1];
    CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    
    total_height = 1000 - line_y + (int) descent + 1;    //+1为了纠正descent转换成int小数点后舍去的值
    
    CTLineRef firstLine = (__bridge CTLineRef)linesArray[0];
    NSArray *runs = (NSArray *)CTLineGetGlyphRuns(firstLine);
    CTRunRef lastRun = (__bridge CTRunRef)([runs objectAtIndex:runs.count - 1]);
    CFRange lastRunRange = CTRunGetStringRange(lastRun);
    CGFloat lastXOffset =CTLineGetOffsetForStringIndex(firstLine, lastRunRange.location + lastRunRange.length, NULL);
    if (linesArray.count == 1)
        total_width = lastXOffset + 1;
    
    CFRelease(textFrame);
    
    return CGSizeMake(total_width, total_height);
}

//返回带行距的文件
+ (NSAttributedString *)getAttributedStingWithString:(NSString *)orginalStr minLineHeight:(float)lineHeight
{
    NSMutableAttributedString *addtionAtt = [[NSMutableAttributedString alloc] initWithString:orginalStr];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.minimumLineHeight = lineHeight;
    [addtionAtt addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, [addtionAtt length])];
    return addtionAtt;
}

#pragma mark - 文件操作
//文件操作
+ (NSString *)createDirectoryWithName:(NSString *)directoryName
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [array objectAtIndex:0];
    NSString *saveDirectoryName = [documentPath stringByAppendingPathComponent:directoryName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:saveDirectoryName])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:saveDirectoryName withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return saveDirectoryName;
}

+ (NSString *)documentPathForFileName:(NSString *)fileName
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [array objectAtIndex:0];
    
    NSString *saveFileName = [documentPath stringByAppendingPathComponent:fileName];
    
    return saveFileName;
}

+ (double)getFileSize:(NSString *)filePath
{
    double filesize = 0;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath])
    {
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:filePath error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            filesize = [theFileSize doubleValue];
    }

    return filesize;
}

#pragma mark - 时间操作
//时间操作
+ (NSString *)getCurrentDate
{
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    [formate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formate stringFromDate:[NSDate date]];
}

+ (NSString *)timeStringFileName
{
    double times = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [[NSString alloc] initWithFormat:@"%.f", times * 1000000];
    return fileName;
}

+ (NSString *)timeStringForWeather
{
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    [formate setDateFormat:@"yyyyMMddHHmm"];
    return [formate stringFromDate:[NSDate date]];
}

//返回时间戳
+ (NSString *)timeStringSince1970
{
    double times = [[NSDate date] timeIntervalSince1970];
    NSString *postTime = [[NSString alloc] initWithFormat:@"%.f", times * 1000];
    return postTime;
}

//通过日期返回时间戳
+ (NSString *)timeStringWithDate:(NSDate *)date
{
    double times = [date timeIntervalSince1970];
    NSString *postTime = [[NSString alloc] initWithFormat:@"%.f", times * 1000];
    return postTime;
}

//通过时间戳返回时间
+ (NSString *)timeWithStamp:(NSString *)intervalString
{
    NSString *timeStr = @"";
    
    double interval = 0;
    if (intervalString.length >= 13)
        interval = intervalString.doubleValue / 1000;
    else
        interval = intervalString.doubleValue;
    
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:interval];
    NSTimeInterval timeInterval = [time timeIntervalSinceNow];
    if (timeInterval < 0)
        timeInterval = -timeInterval;
    
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    [formate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *ZeroTimeStr = [[formate stringFromDate:[NSDate date]] substringWithRange:NSMakeRange(0, 10)];
    ZeroTimeStr = [ZeroTimeStr stringByAppendingString:@" 00:00:00"];
    NSDate *ZeroDate = [formate dateFromString:ZeroTimeStr];
    NSTimeInterval zeroInterval = [ZeroDate timeIntervalSinceNow];
    if (zeroInterval < 0)
        zeroInterval = -zeroInterval;
    
    time = [NSDate dateWithTimeIntervalSince1970:interval + 8 * 3600];
    if (timeInterval < zeroInterval)
    {
        timeStr = [time.description substringWithRange:NSMakeRange(11, 5)];
        timeStr = [@"今天 " stringByAppendingString:timeStr];
    }
    else
    {
        timeStr = [time.description substringWithRange:NSMakeRange(5, 11)];
    }
    
    return timeStr;
}

+ (NSString *)dateStrWithStamp:(NSString *)intervalString
{
    double interval = 0;
    if (intervalString.length >= 13)
        interval = intervalString.doubleValue / 1000;
    else
        interval = intervalString.doubleValue;
    
    interval += 8 * 3600;
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:interval];
    NSString *month = [time.description substringWithRange:NSMakeRange(5, 2)];
    NSString *day = [time.description substringWithRange:NSMakeRange(8, 2)];
    NSString *dateStr = [[NSString alloc] initWithFormat:@"%@月%@日", month, day];
    return dateStr;
}

+ (NSDate *)dateWithString:(NSString *)dateStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.z'Z'"];
    NSDate *date = [formatter dateFromString:dateStr];
    return  date;
}

+ (NSString *)timeBeforeWithStamp:(NSString *)intervalString
{
    double interval = 0;
    if (intervalString.length >= 13)
        interval = intervalString.doubleValue / 1000;
    else
        interval = intervalString.doubleValue;
    
    NSString *dateStr = @"-";
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:interval];
    
    NSTimeInterval timeInterval = [time timeIntervalSinceNow];
    if (timeInterval < 0)
        timeInterval = -timeInterval;
    
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    [formate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *ZeroTimeStr = [[formate stringFromDate:[NSDate date]] substringWithRange:NSMakeRange(0, 10)];
    ZeroTimeStr = [ZeroTimeStr stringByAppendingString:@" 00:00:00"];
    NSDate *ZeroDate = [formate dateFromString:ZeroTimeStr];
    NSTimeInterval zeroInterval = [ZeroDate timeIntervalSinceNow];
    if (zeroInterval < 0)
        zeroInterval = -zeroInterval;
    NSTimeInterval beforeOneDayInterval = zeroInterval + 24 * 3600;
    
    if (timeInterval > beforeOneDayInterval)
    {
        time = [NSDate dateWithTimeIntervalSince1970:interval + 8 * 3600];
        NSString *month = [time.description substringWithRange:NSMakeRange(5, 2)];
        NSString *day = [time.description substringWithRange:NSMakeRange(8, 2)];
        dateStr = [[NSString alloc] initWithFormat:@"%@月%@日", month, day];
    }
    else if (timeInterval > zeroInterval)
        dateStr = @"昨天";
    else if (timeInterval > 3600)
    {
        int hours = (int)timeInterval / 3600;
        dateStr = [[NSString alloc] initWithFormat:@"%i小时前", hours];
    }
    else if (timeInterval > 60)
    {
        int minute = (int)timeInterval / 60;
        dateStr = [[NSString alloc] initWithFormat:@"%i分钟前", minute];
    }
    else
        dateStr = @"刚刚";
    
    return dateStr;
}

+ (NSString *)timeBeforeWithDate:(NSDate *)date
{
    NSTimeInterval timeInterval = [date timeIntervalSinceNow];
    
    NSString *before = @"很久很久以前";
    if (timeInterval < 0)
        timeInterval = -timeInterval;
    
    if (timeInterval > 50 * 24 * 3600)
    {
        NSString *timeStr = [[NSDate dateWithTimeIntervalSince1970:[date timeIntervalSince1970] + 8 * 3600] description];
        before = [timeStr substringWithRange:NSMakeRange(5, 11)];
    }
    else if (timeInterval > 30 * 24 * 3600)
        before = @"一个月前";
    else if (timeInterval > 15 * 24 * 3600)
        before = @"半个月前";
    else if (timeInterval > 7 * 24 * 3600)
        before = @"一周前";
    else if (timeInterval > 24 * 3600)
    {
        int weeks = (int)timeInterval / (24 * 3600);
        before = [[NSString alloc] initWithFormat:@"%i天前", weeks];
    }
    else if (timeInterval > 12 * 3600)
        before = @"半天前";
    else if (timeInterval > 3600)
    {
        int hours = (int)timeInterval / 3600;
        before = [[NSString alloc] initWithFormat:@"%i小时前", hours];
    }
    else if (timeInterval > 1800)
        before = @"半小时前";
    else
        before = @"刚刚";
    
    return before;
}

#pragma mark - 程序版本
//程序版本
+ (NSDictionary *)getCurrentAppInfo
{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDic objectForKey:@"CFBundleDisplayName"];
    NSString *appBuildVersion = [infoDic objectForKey:@"CFBundleVersion"];
    NSString *appCurrentVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:appName, @"appName", appCurrentVersion, @"appCurrentVersion", appBuildVersion, @"appBuildVersion", nil];
    return dic;
}

+ (NSDictionary *)getCurrentDeviceInfo
{
    UIDevice *device = [UIDevice currentDevice];
    NSString *deviceType = [device model];
    NSString *systemName = [device systemName];
    NSString *systemVersion = [device systemVersion];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:deviceType, @"deviceType", systemName, @"systemName", systemVersion, @"systemVersion", nil];
    return dic;
}

#pragma mark - 加密和编码
//加密和编码
+ (NSString *)hmacsha1:(NSString *)data secret:(NSString *)key //hash - "sha1"
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];    
    NSString *hash = [HMAC base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    return hash;
}

//md5加密
+ (NSString *)createMD5:(NSString *)signString
{
    const char*cStr =[signString UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return[NSString stringWithFormat:
           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
           result[0], result[1], result[2], result[3],
           result[4], result[5], result[6], result[7],
           result[8], result[9], result[10], result[11],
           result[12], result[13], result[14], result[15]
           ];
}

+ (NSString *)base64EncodedString:(NSString *)originStr
{
    NSData *originData = [originStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *encodeResult = [originData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return encodeResult;
}

+ (NSString *)base64DecodedString:(NSString *)encodedStr
{
    NSString *formateStr = [encodedStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:formateStr options:0];
    NSString *decodeStr = [[NSString alloc] initWithData:decodeData encoding:NSASCIIStringEncoding];
    return decodeStr;
}

+ (NSString *)urlEncodedString:(NSString *)originStr
{
    NSString *urlEncodeStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)originStr, NULL, (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]", kCFStringEncodingUTF8));
    return urlEncodeStr;
}

#pragma mark - 数据操作
//数据操作
+ (id)jsonObjectWithString:(NSString *)originStr
{
    id result = nil;
    NSString *formateStr = [originStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSData *resultData = [formateStr dataUsingEncoding:NSUTF8StringEncoding];
    result = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
    if(result == nil)
    {
        NSLog(@"========parse Failed!=========");
        result = originStr;
    }
    return result;
}

+ (NSString *)jsonStringWithObject:(id)object
{
    NSString *jsonStr = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}

+ (NSString *)filteredString:(NSString *)originalStr
{
    NSString *newString = originalStr;
    while ([newString hasPrefix:@" "])
        newString = [newString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    while ([newString hasSuffix:@" "])
        newString = [newString stringByReplacingCharactersInRange:NSMakeRange(newString.length - 1, 1) withString:@""];
    
    return newString;
}

#pragma mark - 字符操作
+ (BOOL)isDigital:(NSString *)str
{
    BOOL tag = YES;
    if (![str isEqualToString:@"0"])
    {
        int number = [str intValue];
        if (number == 0)
            tag = NO;
    }
    
    return tag;
}

+ (BOOL)isLetter:(NSString *)str
{
    BOOL tag = YES;
    NSCharacterSet *letterCharacter = [[NSCharacterSet letterCharacterSet] invertedSet];
    NSRange range = [str rangeOfCharacterFromSet:letterCharacter];
    if (range.location != NSNotFound)
        tag = NO;
    
    return tag;
}

+ (BOOL)isChinese:(NSString *)str
{
    BOOL tag = NO;
    
    int a = [str characterAtIndex:0];
    if(0x4e00 <= a && a <= 0x9fa5)
        tag = YES;
    
    return tag;
}

@end
