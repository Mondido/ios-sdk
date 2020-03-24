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

    @synthesize merchant_id,
        amount,currency,
        datetime,
        payment_ref,
        mondido_hash,
        payUrl,
        error_url,
        meta_data,
        success_url,
        test,
        secret,
        template_id,
        webhook,
        customer_ref,
        plan_id,
        subscription_quantity,
        subscription_items,
        items,
        authorize,
        store_card,
        vat_amount;

    ASCompletionBlock paymentCallback;

-(id) init{
    self = [super init];
    if(self)
    {
       meta_data = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (WKWebView*)createWebView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:screenRect];  //Change self.view.bounds to a smaller CGRect if you don't want it to take up the whole screen
    return webView;
}

- (NSString *) randomOrderId{
    int r = arc4random() % 500;
    return [@"test" stringByAppendingFormat:@"%d",r];
    }

- (NSString *) createHash{
    NSString *test_val;
    test_val = @"";
    if ([test isEqualToString:@"true"]){
       test_val = @"test";
    }
    
    return [self md5:[@"" stringByAppendingFormat:@"%@%@%@%@%@%@%@",
                      merchant_id,
                      payment_ref,
                      customer_ref,
                      amount,
                      currency,
                      test_val,
                      secret]];
}

- (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (int)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
       [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

- (void) makeHostedPayment:(WKWebView *)theWebView withCallback:(ASCompletionBlock)callback{
    theWebView.navigationDelegate = self;
    NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
    [postDictionary setObject:amount forKey:@"amount"];
    [postDictionary setObject:currency forKey:@"currency"];
    [postDictionary setObject:merchant_id forKey:@"merchant_id"];
    [postDictionary setObject:payment_ref forKey:@"payment_ref"];
    [postDictionary setObject:mondido_hash forKey:@"hash"];
    [postDictionary setObject:success_url forKey:@"success_url"];
    [postDictionary setObject:error_url forKey:@"error_url"];
    [postDictionary setObject:test forKey:@"test"];
    if(plan_id != nil){
        [postDictionary setObject:plan_id forKey:@"plan_id"];
    }
    if (subscription_quantity != nil) {
        [postDictionary setObject:subscription_quantity forKey:@"amosubscription_quantityunt"];
    }
    if (customer_ref != nil) {
        [postDictionary setObject:customer_ref forKey:@"customer_ref"];
    }
    if (webhook != nil) {
        [postDictionary setObject:webhook forKey:@"webhook"];

    }
    if (subscription_items != nil) {
        [postDictionary setObject:subscription_items forKey:@"subscription_items"];
    }
    if (items != nil) {
        [postDictionary setObject:items forKey:@"items"];
    }
    if (authorize != nil) {
        [postDictionary setObject:authorize forKey:@"authorize"];
    }
    if (store_card != nil) {
        [postDictionary setObject:store_card forKey:@"store_card"];
    }
    if (vat_amount != nil) {
        [postDictionary setObject:vat_amount forKey:@"vat_amount"];
    }

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
        NSString *postLength                = [NSString stringWithFormat:@"%ld", (unsigned long)[postData length]];
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
    NSString *outString = [NSString stringWithString:string];
    outString = [outString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    
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

#pragma mark - WKNavigationDelegate // Delegates

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
   NSLog(@"didFinishNavigation");
   
   //when page is loaded
   NSString *currentUrl = webView.URL.absoluteString;
   
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
       NSLog(@"payment starting");
       //start
   }else{
       NSLog(@"payment error");
       paymentCallback(ERROR);
   }
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
   NSLog(@"didReceiveServerRedirectForProvisionalNavigation");
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
   NSLog(@"didStartProvisionalNavigation");
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
   NSLog(@"decidePolicyForNavigationAction");
   decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
   NSLog(@"decidePolicyForNavigationResponse");
   decisionHandler(WKNavigationResponsePolicyAllow);
}

@end
