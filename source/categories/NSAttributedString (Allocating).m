//
// NSAttributedString (Allocating).m
//
// Copyright (c) 2007 3James Software.
//
// License:
// 
//   Permission is hereby granted, free of charge, to any person obtaining a
//   copy of this software and associated documentation files (the "Software"),
//   to deal in the Software without restriction, including without limitation
//   the rights to use, copy, modify, merge, publish, distribute, sublicense,
//   and/or sell copies of the Software, and to permit persons to whom the
//   Software is furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in
//   all copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//   DEALINGS IN THE SOFTWARE.
//

#import "NSAttributedString (Allocating).h"

@implementation NSAttributedString (Allocating)

+ (NSAttributedString *) attributedStringWithAttributedString: (NSAttributedString *) attributedString
{
  return [[[self alloc] initWithAttributedString: attributedString] autorelease];
}

+ (NSAttributedString *) attributedStringWithString: (NSString *) string
{
  return [[[self alloc] initWithString: string] autorelease];
}

+ (NSAttributedString *) attributedStringWithString: (NSString *) string attributes: (NSDictionary *) dictionary
{
  return [[[self alloc] initWithString: string
                            attributes: dictionary] autorelease];
}

@end

#pragma mark -

@implementation NSMutableAttributedString (Allocating)

+ (NSMutableAttributedString *) attributedStringWithAttributedString: (NSAttributedString *) attributedString
{
  return [[[self alloc] initWithAttributedString: attributedString] autorelease];
}

+ (NSMutableAttributedString *) attributedStringWithString: (NSString *) string
{
  return [[[self alloc] initWithString: string] autorelease];
}

+ (NSMutableAttributedString *) attributedStringWithString: (NSString *) string attributes: (NSDictionary *) dictionary
{
  return [[[self alloc] initWithString: string
                            attributes: dictionary] autorelease];
}

@end
