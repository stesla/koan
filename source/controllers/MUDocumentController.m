//
// MUDocumentController.m
//
// Copyright (c) 2010 3James Software.
//

#import "MUDocumentController.h"

#import "MUTextLogDocument.h"

@implementation MUDocumentController

- (void) closeAllDocumentsWithDelegate: (id) delegate
                   didCloseAllSelector: (SEL) didCloseAllSelector
                           contextInfo: (void *) contextInfo
{
  // TODO: override this to handle closing the log browser.
  // See <http://www.cocoadev.com/index.pl?DocumentBasedAppWithOneWindowForAllDocuments>.
  
  [super closeAllDocumentsWithDelegate: delegate didCloseAllSelector: didCloseAllSelector contextInfo: contextInfo];
}

- (void) noteNewRecentDocument: (NSDocument *) document
{
  if ([document isKindOfClass: [MUTextLogDocument class]])
    return;
  
  [super noteNewRecentDocument: document];
}

@end
