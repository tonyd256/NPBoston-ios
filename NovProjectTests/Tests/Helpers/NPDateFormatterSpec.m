#import "NPDateFormatter.h"
#import "NSDate+Fixture.h"

SpecBegin(NPDateFormatter)

describe(@"NPDateFormatter", ^{
    
    it(@"should format an NSDate to a string", ^{
        NSString *returnedDateString = [[NPDateFormatter sharedFormatter].displayFormatter stringFromDate:[NSDate dateFixture]];
        // this isn't going to work on any time zone except EST ... also might break during day light savings
        expect(returnedDateString).to.equal(@"Fri - Jul 12, 2013 - 10:55AM");
    });
    
    it(@"should create an NSDate object from a string", ^{
        NSDate *date = [[NPDateFormatter sharedFormatter].serverFormatter dateFromString:[[NSDate dateStringFixture] substringToIndex:16]];
        
        expect(date).to.equal([NSDate dateFixture]);
    });
});

SpecEnd
