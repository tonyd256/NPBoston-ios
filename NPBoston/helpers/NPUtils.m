//
//  NPUtils.m
//  NPBoston
//
//  Created by Tony DiPasquale on 7/23/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPUtils.h"
#import "Mixpanel.h"
#import "NPAPIClient.h"

@implementation NPUtils

- (NSString *)reportError:(NSError *)error WithMessage:(NSString *)message FromOperation:(AFJSONRequestOperation *)operation {
    
    NSString *errorMessage;
    
    if ([operation responseJSON] && [[operation responseJSON] objectForKey:@"error"]) {
        errorMessage = [[operation responseJSON] valueForKey:@"error"];
        NSLog(@"Error: %@", errorMessage);
        [[Mixpanel sharedInstance] track:message properties:@{@"error": errorMessage}];
        return errorMessage;
    } else {
        return [self reportError:error WithMessage:message];
    }  
}

- (NSString *)reportError:(NSError *)error WithMessage:(NSString *)message{
    NSLog(@"Error: %@", error.localizedDescription);
    [[Mixpanel sharedInstance] track:message properties:@{@"error": error.localizedDescription}];
    return error.localizedDescription;
}

@end
