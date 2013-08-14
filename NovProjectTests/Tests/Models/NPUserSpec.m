#import "NPUser+Fixture.h"

SpecBegin(NPUser)

describe(@"NPUser model", ^{
    __block NSDictionary *userJSON;
    
    beforeAll(^{
        userJSON = [NPUser jsonFixture];
    });
    
    it(@"should create user model from JSON", ^{
        NPUser *user = [NPUser userWithObject:userJSON];
        expect(user.objectId).to.equal([userJSON valueForKey:@"_id"]);
    });
});

SpecEnd
