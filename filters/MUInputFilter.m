//
//  MUInputFilter.m
//  Koan
//
//  Created by Samuel on 11/12/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "MUInputFilter.h"


@implementation MUInputFilter

- (void) filter:(NSAttributedString *)string
{
  [_successor filter:string];
}

- (void) setSuccessor:(id <MUFiltering>)successor;
{
  _successor = successor;
}

@end
