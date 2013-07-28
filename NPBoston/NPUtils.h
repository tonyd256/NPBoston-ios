//
//  NPUtils.h
//  NPBoston
//
//  Created by Tony DiPasquale on 7/23/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFJSONRequestOperation;

@interface NPUtils : NSObject

+ (NSString *)reportError:(NSError *)error WithMessage:(NSString *)message FromOperation:(AFJSONRequestOperation *)operation;
+ (NSString *)reportError:(NSError *)error WithMessage:(NSString *)message;

@end
