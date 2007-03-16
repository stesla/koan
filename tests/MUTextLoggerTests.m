//
// MUTextLoggerTests.m
//
// Copyright (c) 2006 3James Software
//

#import "MUTextLoggerTests.h"

@interface MUTextLoggerTests (Private)
- (void) assertFilter:(id)object;
- (void) assertFilterString:(NSString *)string;
- (void) assertLoggedOutput:(NSString *)string;
@end

#pragma mark -

@implementation MUTextLoggerTests (Private)

- (void) assertFilter:(id)object
{
  [self assert:[filter filter:object] equals:object message:nil];
}

- (void) assertFilterString:(NSString *)string
{
  [self assertFilter:[NSAttributedString attributedStringWithString:string]];
}

- (void) assertLoggedOutput:(NSString *)string
{
  NSString *outputString = [NSString stringWithCString:(const char *)outputBuffer];
  
  [self assert:outputString equals:string];
}

@end

#pragma mark -

@implementation MUTextLoggerTests

- (void) setUp
{
  memset (outputBuffer, 0, J3TextLogTestBufferMax);
  NSOutputStream *output = [NSOutputStream outputStreamToBuffer:outputBuffer
                                                       capacity:J3TextLogTestBufferMax];
  [output open];
  
  filter = [[MUTextLogger alloc] initWithOutputStream:output];
}

- (void) tearDown
{
  [filter release];
}

- (void) testEmptyString
{
  [self assertFilterString:@""];
  [self assertLoggedOutput:@""];
}

- (void) testSimpleString
{
  [self assertFilterString:@"Foo"];
  [self assertLoggedOutput:@"Foo"];
}

- (void) testColorString
{
  NSMutableAttributedString *string = [NSMutableAttributedString attributedStringWithString:@"Foo"];
  [string addAttribute:NSForegroundColorAttributeName
                 value:[NSColor redColor]
                 range:NSMakeRange (0, [string length])];
  
  [self assertFilter:string];
  [self assertLoggedOutput:@"Foo"];
}

- (void) testFontString
{
  NSMutableAttributedString *string = [NSMutableAttributedString attributedStringWithString:@"Foo"];
  [string addAttribute:NSFontAttributeName
                 value:[NSFont fontWithName:@"Monaco" size:10.0]
                 range:NSMakeRange (0, [string length])];
  
  [self assertFilter:string];
  [self assertLoggedOutput:@"Foo"];
}

- (void) testSimpleConcatenation
{
  [self assertFilterString:@"One"];
  [self assertFilterString:@" "];
  [self assertFilterString:@"Two"];
  [self assertLoggedOutput:@"One Two"];
}

- (void) testEmptyStringConcatenation
{
  [self assertFilterString:@"One"];
  [self assertFilterString:@""];
  [self assertFilterString:@"Two"];
  [self assertLoggedOutput:@"OneTwo"];
}

- (void) testComplexEmptyStringConcatenation
{
  NSMutableAttributedString *one = [NSMutableAttributedString attributedStringWithString:@"One"];
  NSMutableAttributedString *two = [NSMutableAttributedString attributedStringWithString:@"Two"];
  NSMutableAttributedString *empty = [NSMutableAttributedString attributedStringWithString:@""];
  
  [one addAttribute:NSForegroundColorAttributeName
              value:[NSColor redColor]
              range:NSMakeRange (0, [one length])];
  
  [two addAttribute:NSFontAttributeName
              value:[NSFont fontWithName:@"Monaco" size:10.0]
              range:NSMakeRange (0, [two length])];
  
  [empty addAttribute:NSForegroundColorAttributeName
                value:[NSColor greenColor]
                range:NSMakeRange (0, [empty length])];
  
  [self assertFilter:one];
  [self assertFilter:empty];
  [self assertFilter:two];
  [self assertLoggedOutput:@"OneTwo"];
}

@end
