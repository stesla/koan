//
//  MUInputFilter.h
//  Koan
//
//  Created by Samuel on 11/12/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MUFiltering.h"

@interface MUInputFilter : NSObject <MUFiltering> {
  id <MUFiltering> _successor;
}

- (void) filter:(NSAttributedString *)string;
- (void) setSuccessor:(id <MUFiltering>)successor;

@end
