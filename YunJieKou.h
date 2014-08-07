//
//  YunJieKou.h
//  
//  Created by Wu Guoquan on 14-8-7.
//  Copyright (c) 2014 HangZhou Caibo Network Technology Co,.Ltd . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

#define YunJieKou_Server @"http://api.yunjiekou.com/"
#define YunJieKou_Version @"1.0"
#define YunJieKou_AppKey @""
#define YunJieKou_AppSecret @""



@protocol YunJiekouDelegate <NSObject>

@optional
-(void)yunjiekou:(id)yjkObj serverDataGetSuccess:(id)serverData;
-(void)yunjiekou:(id)yjkObj serverDataGetFailure:(id)serverData message:(NSString *)message;

@end

@interface YunJieKou : NSObject<NSURLConnectionDelegate>
{
    NSURLConnection* aSynConnection;
    NSMutableData *returnInfoData;
    
    __weak id <YunJiekouDelegate> _delegate;
}

@property (nonatomic,weak) id <YunJiekouDelegate> delegate;

-(void)req:(NSString *)methodName;
-(void)req:(NSString *)methodName params:(NSDictionary *)params;

@end
