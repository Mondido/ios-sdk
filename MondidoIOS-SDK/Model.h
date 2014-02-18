//
//  Model.h
//  MondidoIOS-SDK
//
//  Created by Robert Pohl on 18/02/14.
//  Copyright (c) 2014 Mondido Payments. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * unit;
@property (nonatomic, retain) NSArray * fields;

- (NSString *)md5Hash;

@end