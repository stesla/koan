//
// GetMetadataForFile.m
//
// Copyright (c) 2007 3James Software
//

#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h> 
#include <Foundation/Foundation.h>
#include "MUKoanLog.h"

Boolean GetMetadataForFile(void* thisInterface, 
			   CFMutableDictionaryRef attributes, 
			   CFStringRef contentTypeUTI,
			   CFStringRef pathToFile)
{
  Boolean success = FALSE;
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  MUKoanLog *log = [MUKoanLog logWithContentsOfFile:(NSString *)pathToFile];
  if (log)
  {
    [log fillDictionaryWithMetadata:(NSMutableDictionary *)attributes];
    success = TRUE;
  }
  [pool release];
  return success;
}
