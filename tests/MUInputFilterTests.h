//
//  MUInputFilterTests.h
//  Koan
//
//  Created by Samuel on 11/12/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ObjcUnit/ObjcUnit.h>

#import "MUFiltering.h"

@interface MUInputFilterTests : TestCase <MUFiltering> {
  NSAttributedString *_output;
}

- (void) filter:(NSAttributedString *)string;

@end
