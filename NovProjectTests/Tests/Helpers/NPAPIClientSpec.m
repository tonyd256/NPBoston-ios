#import "NPAPIClient+StubExtentions.h"
#import "NPWorkout+Fixture.h"

SpecBegin(NPAPIClient)

describe(@"NPAPIClient", ^{    
    describe(@"workout types request", ^{
        __block NSDictionary *workoutTypesResponse;
        __block NSArray *returnedWorkoutTypes;
        
        beforeAll(^{
            workoutTypesResponse = @{@"data": @[@{@"_id": @"1234abc",
                                                  @"type": @"Stadium"},
                                                @{@"_id": @"1235abc",
                                                  @"type": @"Hills"}]};
        });

        beforeEach(^{
            [NPAPIClient stubRequestWithPath:@"workout_types" andHTTPMethod:@"GET"];
        });
        
        it(@"should return an array of workout types", ^{            
            [[NPAPIClient sharedClient] fetchWorkoutTypesWithSuccessBlock:^(NSArray *workoutTypes) {
                returnedWorkoutTypes = workoutTypes;
            }];
            expect(returnedWorkoutTypes).will.equal([workoutTypesResponse objectForKey:@"data"]);
        });

        afterEach(^{
            [NPAPIClient removeLastRequestHandler];
        });
    });

    describe(@"workout request", ^{
        __block NSArray *workoutsJSON;
        __block NSArray *returnedWorkouts;

        beforeAll(^{
            workoutsJSON = @[[NPWorkout jsonFixture],
                             [NPWorkout jsonFixture]];
        });

        beforeEach(^{
            [NPAPIClient stubRequestWithPath:@"workouts" andHTTPMethod:@"GET"];
        });

        it(@"should return an array of workout models", ^{
            [[NPAPIClient sharedClient] fetchWorkoutsForLocation:@"BOS" withSuccessBlock:^(NSArray *workouts) {
                returnedWorkouts = workouts;
            }];
            expect(returnedWorkouts.count).will.equal(2);
        });

        afterEach(^{
            [NPAPIClient removeLastRequestHandler];
        });
    });
});

SpecEnd
