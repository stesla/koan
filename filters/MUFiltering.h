/*
 *  MUFiltering.h
 *  Koan
 *
 *  Created by Samuel on 11/12/04.
 *  Copyright 2004 __MyCompanyName__. All rights reserved.
 *
 */

#include <Carbon/Carbon.h>

@protocol MUFiltering
- (void) filter:(NSAttributedString *)string;
@end
