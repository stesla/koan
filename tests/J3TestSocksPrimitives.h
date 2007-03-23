//
// J3TestSocksPrimitives.h
//
// Copyright (c) 2005, 2006 3James Software
//

#import <Cocoa/Cocoa.h>
#import <J3Testing/J3Testcase.h>

@class J3WriteBuffer;

@interface J3TestSocksPrimitives : J3TestCase 
{
  J3WriteBuffer *buffer;
  NSString *readString;
}

@end
