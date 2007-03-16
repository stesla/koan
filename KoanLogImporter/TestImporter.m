//
// TestImporter.m
//
// Copyright (c) 2007 3James Software
//

#import "TestImporter.h"
#import "MUKoanLog.h"

@implementation TestImporter

- (void) testExtractingOneHeader;
{
  MUKoanLog * log = [MUKoanLog logWithString:@"Foo: Bar\n\nText"];
  [self assert:[log headerForKey:@"Foo"] equals:@"Bar"];
}

- (void) testExtractThreeHeaders;
{
  MUKoanLog * log = [MUKoanLog logWithString:@"Foo: Bar\nBaz: Quux\nDate: 01-01-2001\n\nText"];
  [self assert:[log headerForKey:@"Foo"] equals:@"Bar"];  
  [self assert:[log headerForKey:@"Baz"] equals:@"Quux"];  
  [self assert:[log headerForKey:@"Date"] equals:@"01-01-2001"];  
}

- (void) testContentAfterHeaders;
{
  MUKoanLog * log = [MUKoanLog logWithString:@"Header: Value\nHeader2: Value\n\nBody: text\nIs cool\n"];
  [self assert:[log content] equals:@"Body: text\nIs cool\n"];
}

- (void) testHeadersWithoutColon;
{
  MUKoanLog * log = [MUKoanLog logWithString:@"Foo\nBar\n\nBaz"];
  [self assertNil:log];
}

@end
