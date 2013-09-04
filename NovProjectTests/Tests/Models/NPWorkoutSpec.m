#import "NPWorkout+Fixture.h"
#import "NPVerbal+Fixture.h"
#import "NPResult+Fixture.h"

SPEC_BEGIN(NPWorkoutSpec)

describe(@"NPWorkout model", ^{
    __block NSDictionary *workoutJSON;
    
    beforeAll(^{
        workoutJSON = [NPWorkout jsonFixture];
    });
    
    it(@"should create a workout model from JSON", ^{
        NPWorkout *workout = [NPWorkout workoutWithObject:workoutJSON];
        [[workout.objectId should] equal:[workoutJSON valueForKey:@"_id"]];
    });
    
    it(@"should create one verbal model as the verbal property", ^{
        NPWorkout *workout = [NPWorkout workoutWithObject:workoutJSON];
        [[workout.verbal shouldNot] beNil];
    });
    
    it(@"should create one result model as the result property", ^{
        NPWorkout *workout = [NPWorkout workoutWithObject:workoutJSON];
        [[workout.result shouldNot] beNil];
    });
});

SPEC_END
