//
//  NPErrorHandler.h
//  NovProject
//
//  Created by Tony DiPasquale on 9/5/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

@class AFJSONRequestOperation;

@interface NPErrorHandler : NSObject

+ (void)reportError:(NSError *)error quiet:(BOOL)quiet;
+ (void)reportError:(NSError *)error withAnalyticsEvent:(NSString *)event quiet:(BOOL)quiet;
+ (void)reportError:(NSError *)error withAnalyticsEvent:(NSString *)event fromOperation:(AFJSONRequestOperation *)operation quiet:(BOOL)quiet;

@end
