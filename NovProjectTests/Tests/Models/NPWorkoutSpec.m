#import "NPWorkout+Fixture.h"

SpecBegin(NPWorkout)

describe(@"NPWorkout model", ^{
    __block NSDictionary *workoutJSON;
    
    beforeAll(^{
        workoutJSON = [NPWorkout jsonFixture];
        
    });
    
    it(@"should create a workout model from JSON", ^{
        NPWorkout *workout = [NPWorkout workoutWithObject:workoutJSON];
        expect(workout.objectId).to.equal([workoutJSON valueForKey:@"_id"]);
    });
    
    it(@"should create one verbal model as the verbal property", ^{
        NPWorkout *workout = [NPWorkout workoutWithObject:workoutJSON];
        expect(workout.verbal).toNot.beNil();
    });
    
    it(@"should create one result model as the result property", ^{
        NPWorkout *workout = [NPWorkout workoutWithObject:workoutJSON];
        expect(workout.result).toNot.beNil();
    });
});

SpecEnd
