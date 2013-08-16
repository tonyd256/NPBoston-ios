#import "NPUtils.h"

SpecBegin(NPUtils)

describe(@"NPUtils helper", ^{
    __block NSNumber *timeNumber;
    __block NSString *timeString;
    
    beforeAll(^{
        timeNumber = @5000;
        timeString = @"01:23:20";
    });
    
    it(@"should convert time number to string", ^{
        NSString *str = [NPUtils timeToString:timeNumber];
        expect(str).to.equal(timeString);
    });
    
    it(@"should convert time string to number", ^{
        NSNumber *num = [NPUtils stringToTime:timeString];
        expect(num).to.equal(timeNumber);
    });
});

SpecEnd
