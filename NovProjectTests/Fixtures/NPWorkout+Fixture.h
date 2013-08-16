//
//  NPWorkout+Fixture.h
//  NovProject
//
//  Created by Tony DiPasquale on 8/14/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPWorkout.h"
#import "NPFixtureProtocol.h"

@interface NPWorkout (Fixture) <NPFixtureProtocol>

+ (NSDictionary *)workoutTypeJSONFixture;

@end
