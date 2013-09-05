//
//  NPErrorHandler.m
//  NovProject
//
//  Created by Tony DiPasquale on 9/5/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPErrorHandler.h"
#import "AFJSONRequestOperation.h"

@implementation NPErrorHandler

+ (void)reportError:(NSError *)error quiet:(BOOL)quiet
{
    NSLog(@"Error: %@", error.localizedDescription);

    if (!quiet)
        [self alertUserWithTitle:@"An Error Occured" message:error.localizedDescription];
}

+ (void)reportError:(NSError *)error withAnalyticsEvent:(NSString *)event quiet:(BOOL)quiet
{
    [[NPAnalytics sharedAnalytics] trackError:event message:error.localizedDescription];
    [self reportError:error quiet:quiet];
}

+ (void)reportError:(NSError *)error withAnalyticsEvent:(NSString *)event fromOperation:(AFJSONRequestOperation *)operation quiet:(BOOL)quiet
{
    if (![operation responseJSON] || ![[operation responseJSON] objectForKey:@"error"])
        return [self reportError:error withAnalyticsEvent:event quiet:quiet];
    
    NSString *errorMessage = [[operation responseJSON] valueForKey:@"error"];
    NSLog(@"Error: %@", errorMessage);
    [[NPAnalytics sharedAnalytics] trackError:event message:errorMessage];
    
    if (!quiet) [self alertUserWithTitle:@"An Error Occured" message:errorMessage];
}

+ (void)alertUserWithTitle:(NSString *)title message:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
