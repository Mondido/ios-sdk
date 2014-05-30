//
//  MondidoBase.h
//  MondidoIOS-SDK
//
//  Created by Robert Pohl on 18/02/14.
//  Copyright (c) 2014 Mondido Payments. All rights reserved.
//  Version 1.0

#import <Foundation/Foundation.h>


typedef enum PaymentStatus : NSInteger PaymentStatus;
enum PaymentStatus : NSInteger {
    STARTED,
	SUCCESS,
	FAILED,
	ERROR
};


@interface MondidoBase : NSObject<UIWebViewDelegate>{
    
}
@property (nonatomic, retain) NSString *payUrl;
@property (nonatomic, retain) NSString *amount;
@property (nonatomic, retain) NSString *currency;
@property (nonatomic, retain) NSString *merchant_id;
@property (nonatomic, retain) NSString *datetime;
@property (nonatomic, retain) NSString *payment_ref;
@property (nonatomic, retain) NSString *customer_ref;
@property (nonatomic, retain) NSString *hash;
@property (nonatomic, retain) NSString *success_url;
@property (nonatomic, retain) NSString *error_url;
@property (nonatomic, retain) NSMutableDictionary *meta_data;
@property (nonatomic, retain) NSString *test;
@property (nonatomic, retain) NSString *secret;
@property (nonatomic, retain) NSString *template_id;

- (NSString *) md5:NSString;
- (NSString *) randomOrderId;
- (NSString *) createHash;
- (UIWebView *) createWebView;

typedef void (^ASCompletionBlock)(NSInteger status);

- (void)makeHostedPayment:(UIWebView *)webView withCallback:(ASCompletionBlock)callback;
- (void)setReadyCallback:(ASCompletionBlock)callback;

@end

