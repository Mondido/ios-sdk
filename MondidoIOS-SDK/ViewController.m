//
//  ViewController.m
//  MondidoIOS-SDK
//
//  Created by Robert Pohl on 18/02/14.
//  Copyright (c) 2014 Mondido Payments. All rights reserved.
//

#import "ViewController.h"
#import "MondidoBase.h"

@interface ViewController ()

@end

@implementation ViewController
MondidoBase *mondido;

- (void)viewDidLoad
{
    [super viewDidLoad];

    mondido = [[MondidoBase alloc] init];
    [mondido setReadyCallback:^(NSInteger status){
        //do something when the payment page is loaded, for example hide spinner etc.
    }];

    //mondido.template_id = @"1"; //to hard code the payment template
    [mondido.meta_data setObject:@"productName" forKey:@"metadata[products][1][name]"];
    [mondido.meta_data setObject:@"red" forKey:@"metadata[products][1][color]"];
    
    mondido.payUrl = @"https://pay.mondido.com/v1/form";
    mondido.amount = @"1.00";
    mondido.currency = @"SEK";
    mondido.merchant_id = @"5";
    mondido.secret = @"$2a$10$5OGLq7v86uROMbF3Yfi3kO"; // should not store secret in app.
    mondido.payment_ref = @"test1";
    mondido.hash = @"";
    mondido.success_url = @"https://mondido.com/success";
    mondido.error_url = @"https://mondido.com/fail";
    mondido.test = @"true";
    mondido.payment_ref = mondido.randomOrderId; //just for testing. remove in production.
    mondido.hash = mondido.createHash; //should be loaded from backend
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
