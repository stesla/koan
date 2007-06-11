//
// MUGozer.h
//
// Copyright (c) 2007 3James Software.
//

#include <Cocoa/Cocoa.h>

extern BOOL license_loaded;

extern inline BOOL import_license_file (NSString *filename) __attribute__ ((always_inline));
extern inline BOOL licensed (void) __attribute__ ((always_inline));
