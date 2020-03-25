//
//  ViewController.m
//  MondidoIOS-SDK
//
//  Created by Robert Pohl on 18/02/14.
//  Copyright (c) 2014 Mondido Payments. All rights reserved.
//

#import "ViewController.h"
#import "MondidoBase.h"

@interface ViewController () <WKNavigationDelegate, WKUIDelegate> {
}
@end

@implementation ViewController
MondidoBase *mondido;

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Find your settings here: https://admin.mondido.com/en/settings
    mondido = [[MondidoBase alloc] init];
    //mondido.template_id = @"1"; //to hard code the payment template
    [mondido.meta_data setObject:@"productName" forKey:@"metadata[products][1][name]"];
    [mondido.meta_data setObject:@"red" forKey:@"metadata[products][1][color]"];
    
    mondido.payUrl = @"https://pay.mondido.com/v1/form?lang=en";
    mondido.amount = @"1.00";
    mondido.currency = @"sek"; //must be in lower case
    mondido.merchant_id = @"1985";
    mondido.secret = @"$2a$10$H2kFVNMcFVlhFOodOqGXpu"; // should not store secret in app.
    mondido.payment_ref = @"test1";
    mondido.customer_ref = @"customer1";
    mondido.mondido_hash = @"";
    mondido.success_url = @"https://pay.mondido.com/success";
    mondido.error_url = @"https://pay.mondido.com/fail";
    mondido.test = @"false";
    mondido.webhook = @"{\"trigger\":\"payment_success\",\"email\":\"youremail+ios@gmail.com\"}";
    mondido.payment_ref = mondido.randomOrderId; //just for testing. remove in production.
    mondido.mondido_hash = mondido.createHash; //should be loaded from backend
    
//    uncomment these if you want to start a subscription
//    mondido.plan_id = @"1";
//    mondido.subscription_items = @"{\"artno\": \"001\", \"amount\": 1, \"description\": \"user license2\", \"qty\": 1, \"vat\": 25, \"discount\": 0}]";
    
    // uncomment items if you want to send make invoice payment
    mondido.items = @"[{\"artno\": \"001\", \"amount\": 1, \"description\": \"user license2\", \"qty\": 1, \"vat\": 25, \"discount\": 0}]";
    
    // authorize = true means to reserve a payment
    mondido.authorize = @"false";
    
    // store card to use a token for next payments
    mondido.store_card = @"false";
    
    mondido.vat_amount = @"0.00";
    
    paymentView = mondido.createWebView; //create one here instead of storyboard/xib
    [self.view addSubview:paymentView]; //add view to stage. default is streatched over the whole screen.
    
    [mondido makeHostedPayment:paymentView withCallback:^(PaymentStatus status) {
        if(status == SUCCESS){
            //success
        }else{
            //problems
        }
     }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
