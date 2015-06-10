//
//  ViewController.h
//  MondidoIOS-SDK
//
//  Created by Robert Pohl on 18/02/14.
//  Copyright (c) 2014 Mondido Payments. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIWebViewDelegate>{
@private
    IBOutlet UIWebView *paymentView;
}

@end
