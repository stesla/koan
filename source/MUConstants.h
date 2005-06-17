//
// MUConstants.h
//
// Copyright (c) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>

#pragma mark Application constants.

extern NSString *MUApplicationName;
extern NSString *MUUpdateURL;

#pragma mark User defaults constants.

extern NSString *MUPBackgroundColor;
extern NSString *MUPFontName;
extern NSString *MUPFontSize;
extern NSString *MUPLinkColor;
extern NSString *MUPTextColor;
extern NSString *MUPWorlds;
extern NSString *MUPProfiles;
extern NSString *MUPVisitedLinkColor;

extern NSString *MUPCheckForUpdatesAutomatically;
extern NSString *MUPCheckForUpdatesInterval;
extern NSString *MUPMostRecentVersion;
extern NSString *MUPMostRecentVersionCheckTime;
extern NSString *MUPMostRecentVersionURL;

#pragma mark Notification constants.

extern NSString *MUConnectionWindowControllerWillCloseNotification;
extern NSString *MUConnectionWindowControllerDidReceiveTextNotification;
extern NSString *MUGlobalBackgroundColorDidChangeNotification;
extern NSString *MUGlobalFontDidChangeNotification;
extern NSString *MUGlobalLinkColorDidChangeNotification;
extern NSString *MUGlobalTextColorDidChangeNotification;
extern NSString *MUGlobalVisitedLinkColorDidChangeNotification;
extern NSString *MUWorldsDidChangeNotification;

#pragma mark Toolbar item constants.

extern NSString *MUAddWorldToolbarItem;
extern NSString *MUAddPlayerToolbarItem;
extern NSString *MUEditSelectedRowToolbarItem;
extern NSString *MURemoveSelectedRowToolbarItem;
extern NSString *MUEditProfileForSelectedRowToolbarItem;
extern NSString *MUGoToURLToolbarItem;

#pragma mark Toolbar item localization constants.

extern NSString *MULAddWorld;
extern NSString *MULAddPlayer;
extern NSString *MULEditItem;
extern NSString *MULEditWorld;
extern NSString *MULEditPlayer;
extern NSString *MULGoToURL;
extern NSString *MULRemoveItem;
extern NSString *MULRemoveWorld;
extern NSString *MULRemovePlayer;
extern NSString *MULEditProfile;

#pragma mark Growl constants.

extern NSString *MUGConnectionClosedByErrorName;
extern NSString *MUGConnectionClosedByErrorDescription;
extern NSString *MUGConnectionClosedByServerName;
extern NSString *MUGConnectionClosedByServerDescription;
extern NSString *MUGConnectionClosedName;
extern NSString *MUGConnectionClosedDescription;
extern NSString *MUGConnectionOpenedName;
extern NSString *MUGConnectionOpenedDescription;

#pragma mark Status message localization constants.

extern NSString *MULConnectionOpening;
extern NSString *MULConnectionOpen;
extern NSString *MULConnectionClosed;
extern NSString *MULConnectionClosedByServer;
extern NSString *MULConnectionClosedByError;

#pragma mark Alert panel localization constants.

extern NSString *MULOkay;
extern NSString *MULCancel;
extern NSString *MULNone;
extern NSString *MULNever;
extern NSString *MULYes;
extern NSString *MULNo;

extern NSString *MULConfirmCloseTitle;
extern NSString *MULConfirmCloseMessage;

extern NSString *MULConfirmQuitTitle;
extern NSString *MULConfirmQuitMessageSingular;
extern NSString *MULConfirmQuitMessagePlural;

extern NSString *MULErrorCheckingForUpdatesTitle;
extern NSString *MULErrorCheckingForUpdatesMessage;

extern NSString *MULShouldCheckAutomaticallyForUpdatesTitle;
extern NSString *MULShouldCheckAutomaticallyForUpdatesMessage;

#pragma mark Miscellaneous localization constants.

extern NSString *MULConnect;
extern NSString *MULDisconnect;

extern NSString *MULConnectWithoutLogin;

#pragma mark Miscellaneous other constants.

extern NSString *MUInsertionIndex;
extern NSString *MUInsertionWorld;

#pragma mark ANSI parsing constants

extern NSString *J3ANSIForegroundColorAttributeName;
extern NSString *J3ANSIBackgroundColorAttributeName;
