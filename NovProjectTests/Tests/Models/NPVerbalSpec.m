#import "NPVerbal+Fixture.h"

SPEC_BEGIN(NPVerbalSpec)

describe(@"NPVerbal model", ^{
    __block NSDictionary *verbalJSON;
    
    beforeAll(^{
        verbalJSON = [NPVerbal jsonFixture];
    });
    
    it(@"should create Verbal model from JSON data", ^{
        NPVerbal *verbal = [NPVerbal verbalWithObject:verbalJSON];
        [[verbal.objectId should] equal:[verbalJSON valueForKey:@"_id"]];
    });
});

SPEC_END
