//
//  MondidoBase.h
//  MondidoIOS-SDK
//
//  Created by Robert Pohl on 18/02/14.
//  Copyright (c) 2014 Mondido Payments. All rights reserved.
//  Version 1.0

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <WebKit/WKNavigation.h>

typedef enum PaymentStatus : NSInteger PaymentStatus;
enum PaymentStatus : NSInteger {
   STARTED,
	SUCCESS,
	FAILED,
	ERROR
};


@interface MondidoBase : NSObject<WKNavigationDelegate, WKUIDelegate>{
}

@property (nonatomic, retain) NSString *payUrl;
@property (nonatomic, retain) NSString *amount;
@property (nonatomic, retain) NSString *currency;
@property (nonatomic, retain) NSString *merchant_id;
@property (nonatomic, retain) NSString *datetime;
@property (nonatomic, retain) NSString *payment_ref;
@property (nonatomic, retain) NSString *mondido_hash;
@property (nonatomic, retain) NSString *success_url;
@property (nonatomic, retain) NSString *error_url;
@property (nonatomic, retain) NSMutableDictionary *meta_data;
@property (nonatomic, retain) NSString *test;
@property (nonatomic, retain) NSString *secret;
@property (nonatomic, retain) NSString *template_id;
@property (nonatomic, retain) NSString *customer_ref;
@property (nonatomic, retain) NSString *webhook;
@property (nonatomic, retain) NSString *plan_id;
@property (nonatomic, retain) NSString *subscription_quantity;

@property (nonatomic, retain) NSString *subscription_items;
@property (nonatomic, retain) NSString *items;
@property (nonatomic, retain) NSString *authorize;
@property (nonatomic, retain) NSString *store_card;
@property (nonatomic, retain) NSString *vat_amount;


- (NSString *) md5:NSString;
- (NSString *) randomOrderId;
- (NSString *) createHash;
- (WKWebView *) createWebView;

typedef void (^ASCompletionBlock)(NSInteger status);

- (void)makeHostedPayment:(WKWebView *)webView withCallback:(ASCompletionBlock)callback;

@end
