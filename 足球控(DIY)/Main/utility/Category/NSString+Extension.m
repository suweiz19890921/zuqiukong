//
//  NSString+Extension.m
//  01-QQ聊天布局
//
//  Created by apple on 14-4-2.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}




+ (NSString *)changeTime:(NSString *)created_at
{
    //0 - 60分钟
    //1小时到24小时
    //1天-30天
    //一个月-12个月
    //一年前
    NSString *time = created_at;
    NSDateFormatter *fm = [[NSDateFormatter alloc]init];
    [fm setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    NSDate *dat1 = [fm dateFromString:time];
    NSDate *dat2 = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeInterval = [dat2 timeIntervalSinceDate:dat1];
    if (timeInterval / 60 > 1) {
        timeInterval = timeInterval / 60;
        if (timeInterval / 60 > 1) {
            timeInterval = timeInterval / 60;
            if (timeInterval / 24 > 1) {
                timeInterval = timeInterval / 24;
                if (timeInterval / 30 > 1) {
                    timeInterval = timeInterval / 12;
                    if (timeInterval > 1) {
                        time = @"一年前";
                    }else
                    {
                        time = [NSString stringWithFormat:@"%d月前",(int)timeInterval];
                    }
                }else
                {
                    time = [NSString stringWithFormat:@"%d天前",(int)timeInterval];
                }
    
            }else
            {
                time = [NSString stringWithFormat:@"%d小时前",(int)timeInterval];
            }
        }else
        {
           time = [NSString stringWithFormat:@"%d分钟前",(int)timeInterval];
        }
    }else
    {
        time = @"刚刚";
    }
    return time;
}


- (long long)fileSize
{
    // 1.文件管理者
    NSFileManager *mgr = [NSFileManager defaultManager];
    
    // 2.判断file是否存在
    BOOL isDirectory = NO;
    BOOL fileExists = [mgr fileExistsAtPath:self isDirectory:&isDirectory];
    // 文件\文件夹不存在
    if (fileExists == NO) return 0;
    
    // 3.判断file是否为文件夹
    if (isDirectory) { // 是文件夹
        NSArray *subpaths = [mgr contentsOfDirectoryAtPath:self error:nil];
        long long totalSize = 0;
        for (NSString *subpath in subpaths) {
            NSString *fullSubpath = [self stringByAppendingPathComponent:subpath];
            totalSize += [fullSubpath fileSize];
        }
        return totalSize;
    } else { // 不是文件夹, 文件
        // 直接计算当前文件的尺寸
        NSDictionary *attr = [mgr attributesOfItemAtPath:self error:nil];
        return [attr[NSFileSize] longLongValue];
    }
}

@end
