//
//  MUAnsiRemovingFilter.h
//  Koan
//
//  Created by Samuel on 11/14/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MUInputFilter.h"

@interface MUAnsiRemovingFilter : MUInputFilter
{
}

+ (MUInputFilter *) filter;
- (void) filter:(NSString *)string;

@end
