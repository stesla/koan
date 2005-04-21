//
// MUConstants.h
//
// Copyright (c) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>

// Application constants.

extern NSString *MUApplicationName;
extern NSString *MUUpdateURL;

// User defaults constants.

extern NSString *MUPBackgroundColor;
extern NSString *MUPFontName;
extern NSString *MUPFontSize;
extern NSString *MUPLinkColor;
extern NSString *MUPTextColor;
extern NSString *MUPWorlds;
extern NSString *MUPProfiles;
extern NSString *MUPVisitedLinkColor;

// Notification constants.

extern NSString *MUConnectionWindowControllerWillCloseNotification;
extern NSString *MUConnectionWindowControllerDidReceiveTextNotification;
extern NSString *MUGlobalBackgroundColorDidChangeNotification;
extern NSString *MUGlobalFontDidChangeNotification;
extern NSString *MUGlobalLinkColorDidChangeNotification;
extern NSString *MUGlobalTextColorDidChangeNotification;
extern NSString *MUGlobalVisitedLinkColorDidChangeNotification;
extern NSString *MUWorldsDidChangeNotification;

// Toolbar item constants.

extern NSString *MUAddWorldToolbarItem;
extern NSString *MUAddPlayerToolbarItem;
extern NSString *MUEditSelectedRowToolbarItem;
extern NSString *MURemoveSelectedRowToolbarItem;
extern NSString *MUEditProfileForSelectedRowToolbarItem;

// Toolbar item localization constants.

extern NSString *MULAddWorld;
extern NSString *MULAddPlayer;
extern NSString *MULEditItem;
extern NSString *MULEditWorld;
extern NSString *MULEditPlayer;
extern NSString *MULRemoveItem;
extern NSString *MULRemoveWorld;
extern NSString *MULRemovePlayer;
extern NSString *MULEditProfile;

// Growl constants.

extern NSString *MUGConnectionClosedByErrorName;
extern NSString *MUGConnectionClosedByErrorDescription;
extern NSString *MUGConnectionClosedByServerName;
extern NSString *MUGConnectionClosedByServerDescription;
extern NSString *MUGConnectionClosedName;
extern NSString *MUGConnectionClosedDescription;
extern NSString *MUGConnectionOpenedName;
extern NSString *MUGConnectionOpenedDescription;

// Status message localization constants.

extern NSString *MULConnectionOpening;
extern NSString *MULConnectionOpen;
extern NSString *MULConnectionClosed;
extern NSString *MULConnectionClosedByServer;
extern NSString *MULConnectionClosedByError;

// Alert panel localization constants.

extern NSString *MULOkay;
extern NSString *MULCancel;

extern NSString *MULConfirmCloseTitle;
extern NSString *MULConfirmCloseMessage;

extern NSString *MULConfirmQuitTitle;
extern NSString *MULConfirmQuitMessageSingular;
extern NSString *MULConfirmQuitMessagePlural;

// Miscellaneous localization constants.

extern NSString *MULConnect;
extern NSString *MULDisconnect;

extern NSString *MULConnectWithoutLogin;

// Miscellaneous other constants.

extern NSString *MUInsertionIndex;
extern NSString *MUInsertionWorld;

// ANSI parsing constants

extern NSString *J3ANSIForegroundColorAttributeName;
extern NSString *J3ANSIBackColorAttributeName;
