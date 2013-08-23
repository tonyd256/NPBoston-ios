//
//  NPAPIClient+StubExtentions.h
//  NovProject
//
//  Created by Tony DiPasquale on 8/20/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPAPIClient.h"

@interface NPAPIClient (StubExtentions)

+ (void)stubRequestWithPath:(NSString *)path andHTTPMethod:(NSString *)method;
+ (void)removeLastRequestHandler;

@end
