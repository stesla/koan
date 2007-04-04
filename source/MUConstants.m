//
// MUConstants.m
//
// Copyright (c) 2007 3James Software. All rights reserved.
//

#import "MUConstants.h"

#pragma mark Application constants.

NSString *MUApplicationName = @"Koan";
NSString *MUUpdateURL = @"http: //www.3james.com/updates/com.3james.Koan.plist";

#pragma mark User defaults constants.

NSString *MUPBackgroundColor = @"MUPBackgroundColor";
NSString *MUPFontName = @"MUPFontName";
NSString *MUPFontSize = @"MUPFontSize";
NSString *MUPLinkColor = @"MUPLinkColor";
NSString *MUPTextColor = @"MUPTextColor";
NSString *MUPWorlds = @"MUPWorlds";
NSString *MUPProfiles = @"MUPProfiles";
NSString *MUPVisitedLinkColor = @"MUPVisitedLinkColor";
NSString *MUPProxySettings = @"MUPProxySettings";
NSString *MUPUseProxy = @"MUPUseProxy";

NSString *MUPPlaySounds = @"MUPPlaySounds";
NSString *MUPPlayWhenActive = @"MUPPlayWhenActive";
NSString *MUPSoundChoice = @"MUPSoundChoice";

#pragma mark Notification constants.

NSString *MUConnectionWindowControllerWillCloseNotification = @"MUConnectionWindowControllerWillCloseNotification";
NSString *MUConnectionWindowControllerDidReceiveTextNotification = @"MUConnectionWindowControllerDidReceiveTextNotification";
NSString *MUGlobalBackgroundColorDidChangeNotification = @"MUGlobalBackgroundColorDidChangeNotification";
NSString *MUGlobalFontDidChangeNotification = @"MUGlobalFontDidChangeNotification";
NSString *MUGlobalLinkColorDidChangeNotification = @"MUGlobalLinkColorDidChangeNotification";
NSString *MUGlobalTextColorDidChangeNotification = @"MUGlobalTextColorDidChangeNotification";
NSString *MUGlobalVisitedLinkColorDidChangeNotification = @"MUGlobalVisitedLinkColorDidChangeNotification";
NSString *MUWorldsDidChangeNotification = @"MUWorldsDidChangeNotification";

NSString *J3ReadBufferDidProvideStringNotification = @"J3ReadBufferDidProvideStringNotification";

#pragma mark Toolbar item constants.

NSString *MUAddWorldToolbarItem = @"MUAddWorldToolbarItem";
NSString *MUAddPlayerToolbarItem = @"MUAddPlayerToolbarItem";
NSString *MUEditSelectedRowToolbarItem = @"MUEditSelectedRowToolbarItem";
NSString *MURemoveSelectedRowToolbarItem = @"MURemoveSelectedRowToolbarItem";
NSString *MUEditProfileForSelectedRowToolbarItem = @"MUEditProfileForSelectedRowToolbarItem";
NSString *MUGoToURLToolbarItem = @"MUGoToURLToolbarItem";

#pragma mark Toolbar item localization constants.

NSString *MULAddWorld = @"AddWorld";
NSString *MULAddPlayer = @"AddPlayer";
NSString *MULEditItem = @"EditItem";
NSString *MULEditWorld = @"EditWorld";
NSString *MULEditPlayer = @"EditPlayer";
NSString *MULGoToURL = @"GoToURL";
NSString *MULRemoveItem = @"RemoveItem";
NSString *MULRemoveWorld = @"RemoveWorld";
NSString *MULRemovePlayer = @"RemovePlayer";
NSString *MULEditProfile = @"EditProfile";

#pragma mark Growl localization constants.

NSString *MUGConnectionClosedByErrorName = @"GrowlConnectionClosedByErrorName";
NSString *MUGConnectionClosedByErrorDescription = @"GrowlConnectionClosedByErrorDescription";
NSString *MUGConnectionClosedByServerName = @"GrowlConnectionClosedByServerName";
NSString *MUGConnectionClosedByServerDescription = @"GrowlConnectionClosedByServerDescription";
NSString *MUGConnectionClosedName = @"GrowlConnectionClosedName";
NSString *MUGConnectionClosedDescription = @"GrowlConnectionClosedDescription";
NSString *MUGConnectionOpenedName = @"GrowlConnectionOpenedName";
NSString *MUGConnectionOpenedDescription = @"GrowlConnectionOpenedDescription";

#pragma mark Status message localization constants.

NSString *MULConnectionOpening = @"ConnectionOpening";
NSString *MULConnectionOpen = @"ConnectionOpen";
NSString *MULConnectionClosed = @"ConnectionClosed";
NSString *MULConnectionClosedByServer = @"ConnectionClosedByServer";
NSString *MULConnectionClosedByError = @"ConnectionClosedByError";

#pragma mark Alert panel localization constants.

NSString *MULOK = @"OK";
NSString *MULConfirm = @"Confirm";
NSString *MULQuitImmediately = @"QuitImmediately";
NSString *MULCancel = @"Cancel";

NSString *MULConfirmCloseTitle = @"ConfirmCloseTitle";
NSString *MULConfirmCloseMessage = @"ConfirmCloseMessage";

NSString *MULConfirmQuitTitleSingular = @"ConfirmQuitTitleSingular";
NSString *MULConfirmQuitTitlePlural = @"ConfirmQuitTitlePlural";
NSString *MULConfirmQuitMessage = @"ConfirmQuitMessage";

#pragma mark Miscellaneous localization constants.

NSString *MULConnect = @"Connect";
NSString *MULDisconnect = @"Disconnect";

NSString *MULConnectWithoutLogin = @"ConnectWithoutLogin";

#pragma mark Miscellaneous other constants.

NSString *MUInsertionIndex = @"MUInsertionIndex";
NSString *MUInsertionWorld = @"MUInsertionWorld";

#pragma mark ANSI parsing constants.

NSString *J3ANSIForegroundColorAttributeName = @"J3ANSIForegroundColorAttributeName";
NSString *J3ANSIBackgroundColorAttributeName = @"J3ANSIBackgroundColorAttributeName";
