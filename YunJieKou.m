//
//  YunJieKou.h
//  
//  Created by Wu Guoquan on 14-8-7.
//  Copyright (c) 2014 HangZhou Caibo Network Technology Co,.Ltd . All rights reserved.
//

#import "YunJieKou.h"

@implementation YunJieKou

@synthesize delegate = _delegate;

-(void)req:(NSString *)methodName
{
    [self req:methodName params:nil];
}

-(void)req:(NSString *)methodName params:(NSMutableDictionary *)params
{
    NSMutableDictionary *mDic;
    if(!params)
    {
        mDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    }else{
        mDic = params;
    }
    
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
    
    [mDic setObject:YunJieKou_AppKey forKey:@"appkey"];
    [mDic setObject:YunJieKou_Version forKey:@"v"];
    [mDic setObject:[NSString stringWithFormat:@"%d",timeStampObj.intValue] forKey:@"timestamp"];
    //[mDic setObject:methodName forKey:@"method"];
    [mDic setObject:@"json" forKey:@"format"];

    
    NSString *sign = [self getSign:mDic method:methodName];
    NSString *urlString = [NSString stringWithFormat:@"%@%@?%@sign=%@",YunJieKou_Server,methodName,[self dicToString:mDic],sign];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: urlString]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval: 60];
    [request setHTTPShouldHandleCookies:FALSE];
    [request setHTTPMethod:@"GET"];
    
    aSynConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}



-(NSString *)dicToString:(NSDictionary *)dic
{
    NSString *kvs = @"";
    for (NSString *key in dic) {
        kvs = [NSString stringWithFormat:@"%@%@=%@&",kvs,key,[self encode:dic[key]]];
        
    }
    
    return kvs;
}


-(NSString *)getSign:(NSDictionary *)params method:(NSString *)method
{
    NSArray *myKeys = [params allKeys];
    NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    NSString *kvs = @"";
    for (NSString *key in sortedKeys) {
        kvs = [NSString stringWithFormat:@"%@%@%@",kvs,key,[self encode:params[key]]];
    }
    
    kvs = [NSString stringWithFormat:@"%@%@%@%@",YunJieKou_AppSecret,kvs,method,YunJieKou_AppSecret];
    return  [self md5:kvs];
}


- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ]; 
}


-(NSString *)encode:(NSString *)strURL
{
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                        (__bridge CFStringRef)strURL, NULL,
                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                        kCFStringEncodingUTF8);
}


#pragma mark- NSURLConnectionDelegate 协议方法


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse{
    returnInfoData=[[NSMutableData alloc] init];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [returnInfoData appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if([_delegate respondsToSelector:@selector(yunjiekou:serverDataGetFailure:message:code:)])
    {
        [_delegate yunjiekou:self serverDataGetFailure:nil message:@"Network Error" code:300000001];
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if( [connection isEqual: aSynConnection])
    {
        NSError *error;
        NSDictionary *respDic = [NSJSONSerialization JSONObjectWithData:returnInfoData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&error];
        if(respDic)
        {
            if([_delegate respondsToSelector:@selector(yunjiekou:serverDataGetSuccess:message:code:)])
            {
                [_delegate yunjiekou:self serverDataGetSuccess:[respDic objectForKey:@"data"] message:[respDic objectForKey:@"message"] code:[[respDic objectForKey:@"code"] intValue]];
            }
        }else{
            if([_delegate respondsToSelector:@selector(yunjiekou:serverDataGetFailure:message:code:)])
            {
                [_delegate yunjiekou:self serverDataGetFailure:nil message:@"Data Deserialize Failure" code:300000002];
            }
        }

    }
}



@end
