//
//  J3NaiveANSIFilterTests.m
//  Koan
//
//  Created by Samuel on 1/25/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3NaiveANSIFilterTests.h"

#import "J3NaiveANSIFilter.h"

@interface J3NaiveANSIFilterTests (Private)
- (NSAttributedString *) makeString:(NSString *)string;
@end

@implementation J3NaiveANSIFilterTests

- (void) testNoCode
{
  NSAttributedString *input = [self makeString:@"Foo"];
  J3NaiveANSIFilter *filter;
  
  filter = (J3NaiveANSIFilter *)[J3NaiveANSIFilter filter];
  [self assertAttributedString:[filter filter:input]
                  stringEquals:@"Foo"];
}

@end

@implementation J3NaiveANSIFilterTests (Private)
- (NSAttributedString *) makeString:(NSString *)string
{
  return [NSAttributedString attributedStringWithString:string];
}



@end
