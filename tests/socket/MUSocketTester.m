//
//  MUSocketTester.m
//  Koan
//
//  Created by Samuel on 8/7/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "MUSocketTester.h"


@implementation MUSocketTester


- (void) socket:(MUSocketConnection *)socket didReadData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData: data encoding: NSASCIIStringEncoding];
    NSLog(@"The Time Is:\n");
    NSLog(string);
    [string release];
}

@end
