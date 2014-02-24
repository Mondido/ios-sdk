//
//  MondidoBase.m
//  MondidoIOS-SDK
//
//  Created by Robert Pohl on 18/02/14.
//  Copyright (c) 2014 Mondido Payments. All rights reserved.
//  Version 1.0

#import "MondidoBase.h"
#import <CommonCrypto/CommonDigest.h>
#include <stdlib.h>

@implementation MondidoBase

    @synthesize merchant_id,amount,currency,datetime,order_id,hash,payUrl,error_url,meta_data,success_url,test,secret,template_id;
    ASCompletionBlock paymentCallback;

-(id) init{
    self = [super init];
    if(self)
    {
       meta_data = [[NSMutableDictionary alloc]init];
    }
    return self;
}
- (UIWebView*)createWebView{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:screenRect];  //Change self.view.bounds to a smaller CGRect if you don't want it to take up the whole screen
    return webView;
}

- (NSString *) randomOrderId{
    int r = arc4random() % 500;
    return [@"test" stringByAppendingFormat:@"%d",r];
    }

- (NSString *) createHash{
    return [self md5:[@"" stringByAppendingFormat:@"%@%@%@%@",merchant_id,order_id,amount,secret]];
}

- (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

- (void) makeHostedPayment:(UIWebView *)theWebView withCallback:(ASCompletionBlock)callback{
    theWebView.delegate = self;
    NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                    amount, @"amount",
                                    currency, @"currency",
                                    merchant_id, @"merchant_id",
                                    order_id, @"order_id",
                                    hash, @"hash",
                                    success_url, @"success_url",
                                    error_url, @"error_url",
                                    test, @"test",
                                    nil];

    //loop meta_data and add those to the post
    for (NSString* key in meta_data) {
        id value = [meta_data objectForKey:key];
         [postDictionary setObject:value forKey:key];
    }
    
    NSURL *url                          = [NSURL URLWithString:self.payUrl];
    NSMutableURLRequest *request        = [NSMutableURLRequest requestWithURL:url
                                                                  cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                              timeoutInterval:60.0];
    
    
    // DATA TO POST
    if(postDictionary) {
        NSString *postString                = [self getFormDataString:postDictionary];
        NSData *postData                    = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *postLength                = [NSString stringWithFormat:@"%d", [postData length]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
    }
    
    [theWebView loadRequest:request];
    
    paymentCallback = callback;
}


- (NSString *)getFormDataString:(NSMutableDictionary*)dictionary {
    if( ! dictionary) {
        return nil;
    }
    NSArray* keys                               = [dictionary allKeys];
    NSMutableString* resultString               = [[NSMutableString alloc] init];
    for (int i = 0; i < [keys count]; i++)  {
        NSString *key                           = [NSString stringWithFormat:@"%@", [keys objectAtIndex: i]];
        NSString *value                         = [NSString stringWithFormat:@"%@", [dictionary valueForKey: [keys objectAtIndex: i]]];
        
        NSString *encodedKey                    = [self escapeString:key];
        NSString *encodedValue                  = [self escapeString:value];
        
        NSString *kvPair                        = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
        if(i > 0) {
            [resultString appendString:@"&"];
        }
        [resultString appendString:kvPair];
    }
    return resultString;
}

- (NSString *)escapeString:(NSString *)string {
    if(string == nil || [string isEqualToString:@""]) {
        return @"";
    }
    NSString *outString     = [NSString stringWithString:string];
    outString                   = [outString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // BUG IN stringByAddingPercentEscapesUsingEncoding
    // WE NEED TO DO several OURSELVES
    outString                   = [self replace:outString lookFor:@"&" replaceWith:@"%26"];
    outString                   = [self replace:outString lookFor:@"?" replaceWith:@"%3F"];
    outString                   = [self replace:outString lookFor:@"=" replaceWith:@"%3D"];
    outString                   = [self replace:outString lookFor:@"+" replaceWith:@"%2B"];
    outString                   = [self replace:outString lookFor:@";" replaceWith:@"%3B"];
    
    return outString;
}
- (NSString *)replace:(NSString *)originalString lookFor:(NSString *)find replaceWith:(NSString *)replaceWith {
    if ( ! originalString || ! find) {
        return originalString;
    }
    
    if( ! replaceWith) {
        replaceWith                 = @"";
    }
    
    NSMutableString *mstring        = [NSMutableString stringWithString:originalString];
    NSRange wholeShebang            = NSMakeRange(0, [originalString length]);
    
    [mstring replaceOccurrencesOfString: find
                             withString: replaceWith
                                options: 0
                                  range: wholeShebang];
    
    return [NSString stringWithString: mstring];
}

//delegates
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    //when page is loaded
    NSString *currentUrl = webView.request.URL.absoluteString;
    
    NSString *successCompare = @"";
    NSString *failCompare = @"";
    if(currentUrl.length >= success_url.length){
        successCompare = [currentUrl substringToIndex:success_url.length];
    }
    if(currentUrl.length >= error_url.length){
        failCompare = [currentUrl substringToIndex:error_url.length];
    }
    
    
    if([currentUrl rangeOfString:@"status=approved"].location != NSNotFound){
         NSLog(@"payment success");
        paymentCallback(SUCCESS);
    }else if([currentUrl rangeOfString:@"status=declined"].location != NSNotFound){
        NSLog(@"payment fail");
        paymentCallback(FAILED);
    }else if([currentUrl isEqualToString:payUrl]){
        NSLog(@"payment staring");
        //start
    }else{
        NSLog(@"payment error");
        paymentCallback(ERROR);
    }
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webview started loading");
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error is %@", [error localizedDescription]);
}




@end
