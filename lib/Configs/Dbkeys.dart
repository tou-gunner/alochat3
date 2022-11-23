//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

// ignore: todo
//TODO:  WARNING:    DO NOT EDIT THIS PAGE UNLESS YOU ARE A DEVELOPER. THIS PAGE HAS ALL THE KEYS USED IN FIRESTORE DATABASE -----
import 'package:cloud_firestore/cloud_firestore.dart';

class Dbkeys {
  //------- device info
  static const String deviceInfoDEVICEID = 'Device ID';
  static const String deviceInfoOSID = 'Os ID';
  static const String deviceInfoMODEL = 'Model';
  static const String deviceInfoOSVERSION = 'OS version';
  static const String deviceInfoOS = 'OS type';
  static const String deviceInfoDEVICENAME = 'Device name';
  static const String deviceInfoMANUFACTURER = 'Manufacturer';
  static const String deviceInfoLOGINTIMESTAMP = 'Device login Time';
  static const String deviceInfoISPHYSICAL = 'Is Physical';
  //-----

  static const String userapp = 'userapp';
  static const String latestappversionandroid = 'latestappversionandroid';
  static const String latestappversionios = 'latestappversionios';
  static const String latestappversionweb = 'latestappversionweb';
  static const String appsettings = 'appsettings';
  static const String totalvisitsANDROID = 'totalvisitsANDROID';
  static const String totalvisitsIOS = 'totalvisitsIOS';
  //---

  static const String issetupdone = 'xhxaxftaft';
  static const String isupdatemandatory = 'isupdatemandatory';
  static const String isappunderconstructionandroid =
      'isappunderconstructionandroid';
  static const String isappunderconstructionios = 'isappunderconstructionios';
  static const String isappunderconstructionweb = 'isappunderconstructionweb';
  static const String isaccountapprovalbyadminneeded =
      'isaccountapprovalbyadminneeded';
  static const String accountapprovalmessage = 'accountapprovalmessage';

  static const String alloweddebuggersUID = 'alloweddebuggersUID';
  static const String isblockedCOD = 'isblockedCOD';
  static const String isblocknewlogins = 'isblocknewlogins';
  static const String maintainancemessage = 'maintainancemessage';
  static const String isshowerrorlog = 'isshowerrorlog';
  static const String newapplinkandroid = 'newapplinkandroid';
  static const String newapplinkios = 'newapplinkios';
  static const String newapplinkweb = 'newapplinkweb';

  static const String iscallsallowed = 'iscallsallowed';
  static const String ismediamessageallowed = 'ismediamessageallowed';
  static const String istextmessageallowed = 'istextmessageallowed';
  static const String isadmobshow = 'isadmobshow';
  static const String isemulatorallowed = 'isemlalwd';
  static const String privacypolicy = 'ppl';
  static const String tnc = 'tnc';
  static const String tncTYPE = 'tncType';
  static const String privacypolicyTYPE = 'pplType';
  static const String url = 'url';
  static const String file = 'file';
  static const String usersidesetupdone = 'usersidesetupdone';
  static const String updateV7done = 'updateV7done';
  static const String adminsidesetupdone = 'adminsidesetupdone';
//-added in update-
  static const String isCallFeatureTotallyHide = 'isCallFeatureTotallyHide';
  static const String maxFileSizeAllowedInMB = 'maxFileSizeAllowedInMB';
  static const String is24hrsTimeformat = 'is24hrsTimeformat';
  static const String isPercentProgressShowWhileUploading =
      'isPercentProgressShowWhileUploading';

  static const String isAllowCreatingGroups = 'isAllowCreatingGroups';
  static const String isAllowCreatingBroadcasts = 'isAllowCreatingBroadcasts';
  static const String isAllowCreatingStatus = 'isAllowCreatingStatus';
  static const String groupMemberslimit = 'groupmemberslimit';
  static const String statusDeleteAfterInHours = 'statusDeleteAfterInHours';
  static const String broadcastMemberslimit = 'broadcastMemberslimit';
  static const String feedbackEmail = 'feedbackEmail';
  static const String isLogoutButtonShowInSettingsPage =
      'isLogoutButtonShowInSettingsPage';

  // Status--------
  static const String sTATUSblocked = 'blocked';
  static const String sTATUSallowed = 'allowed';
  static const String sTATUSpending = 'pending';
  static const String sTATUSdeleted = 'deleted';

  static const String totalapprovedusers = 'totalapprovedusers';
  static const String totalblockedusers = 'totalblockedusers';
  static const String totalpendingusers = 'totalpendingusers';
  static const String totalusers = 'totalusers';
  //---
  static const String nOTIFICATIONisunseen = 'isunseen';
  static const String nOTIFICATIONxxauthor = 'author';
  static const String nOTIFICATIONxxtitle = 'title';
  static const String nOTIFICATIONxxdesc = 'desc';
  static const String nOTIFICATIONxxaction = 'action';
  static const String nOTIFICATIONxximageurl = 'imageurl';
  static const String nOTIFICATIONxxlastupdate = 'lastupdated';
  static const String nOTIFICATIONxxpagecomparekey = 'comparekey';
  static const String nOTIFICATIONxxpagecompareval = 'compareval';
  static const String nOTIFICATIONxxparentid = 'parentid';
  static const String nOTIFICATIONxxextrafield = 'extrafield';
  static const String nOTIFICATIONxxpagetype = 'pagetype';
  static const String nOTIFICATIONxxpageID = 'pageid';

  static const String nOTIFICATIONpagetypeAllDOCSNAPLIST = 'AllDOCSNAPLIST';
  static const String nOTIFICATIONpagetypeSingleDOCinDOCSNAPLIST =
      'SingleDOCinDOCSNAPLIST';
  static const String nOTIFICATIONpagetypeSingleLISTinDOCSNAP =
      'SingleLISTinDOCSNAP';
  static const String nOTIFICATIONpagecollection1 = 'collection1';
  static const String nOTIFICATIONpagedoc1 = 'doc1';
  static const String nOTIFICATIONpagecollection2 = 'collection2';
  static const String nOTIFICATIONpagedoc2 = 'doc2';
  static const String nOTIFICATIONtopic = 'topic';
  static const String nOTIFICATIONactionPUSH = 'PUSH';

//--
  static const String topicUSERS = 'USERS';
  static const String topicPARTICULARUSER = 'PUSER';
  static const String topicADMIN = 'ADMIN';
  static const String topicUSERSandroid = 'USERS-ANDROID';
  static const String topicUSERSios = 'USERS-IOS';
  static const String topicUSERSweb = 'USERS-WEB';

  //---
  static const String docid = 'docid';
  static const String list = 'list';
  //--
  static const String audiocallsmade = 'audiocallsmade';
  static const String videocallsmade = 'videocallsmade';
  static const String mediamessagessent = 'mediamessagessent';
  //---   All Status Fileds-
  static const String statusPUBLISHERPHONE = 'phone';
  static const String statusPUBLISHERPHONEVARIANTS = 'phoneVariants';
  static const String statusPUBLISHEDON = 'publishedOn';
  static const String statusEXPIRININGON = 'expiringOn';
  static const String statusITEMSLIST = 'itemsList';
  static const String statusVIEWERLIST = 'viewerList';
  static const String statusVIEWERLISTWITHTIME = 'viewerListwithtime';
  //----
  static const String statusItemID = 'id';
  static const String statusItemCAPTION = 'caption';
  static const String statusItemBGCOLOR = 'bgcolor';
  static const String statusItemURL = 'url';
  static const String statusItemDURATION = 'duration';
  static const String statusItemTYPE = 'type';
  //----
  static const String statustypeIMAGE = 'img';
  static const String statustypeIMAGEwithcaption = 'imgcap';
  static const String statustypeVIDEO = 'vdo';
  static const String statustypeTEXT = 'text';
  //---   All Group Chat Fileds-
  static const String groupMUTEDMEMBERS = 'muted';
  static const String groupPHOTOURL = 'photourl';
  static const String groupNAME = 'name';
  static const String groupTYPE = 'type';
  static const String groupID = 'id';
  static const String groupIDfiltered = 'iDfltrd';
  static const String groupDESCRIPTION = 'description';
  static const String groupMEMBERSLIST = 'memberslist';
  static const String groupCREATEDBY = 'createdby';
  static const String groupCREATEDON = 'createdon';
  static const String groupLATESTMESSAGETIME = 'latesttimestamp';
  static const String groupADMINLIST = 'adminlist';
  static const String groupISTYPINGUSERID = 'istypingID';
  //-
  static const String groupTYPEonlyadminmessageallowed =
      'Only Admin Messages Allowed';
  static const String groupTYPEallusersmessageallowed =
      'Both User & Admin Messages Allowed';
  //--
  static const String groupmsgCONTENT = 'content';
  static const String groupmsgLISToptional = 'list';
  static const String groupmsgTIME = 'timestamp';
  static const String groupmsgSENDBY = 'sendby';
  static const String groupmsgISDELETED = 'isDeleted';
  static const String groupmsgTYPE = 'type';
  static const String groupmsgISMEDIA = 'ismedia';
  static const String groupmsgNOTIFICATIONtitle = 'nTitle';
  static const String groupmsgNOTIFICATIONdescription = 'nDesc';
  //------
  static const String groupmsgTYPEnotificationCreatedGroup = 'createdgroup';
  static const String groupmsgTYPEnotificationUpdatedGroupDetails =
      'updatedgroupdetails';
  static const String groupmsgTYPEnotificationUpdatedGroupicon =
      'updatedgroupdetailsicon';
  static const String groupmsgTYPEnotificationDeletedGroupicon =
      'updatedgroupdetailsicon';
  static const String groupmsgTYPEnotificationUserSetAsAdmin = 'UserSetAsAdmin';
  static const String groupmsgTYPEnotificationUserRemovedAsAdmin =
      'UserRemovedAsAdmin';
  static const String groupmsgTYPEnotificationAddedUser = 'addeduser';
  static const String groupmsgTYPEnotificationRemovedUser = 'removeduser';
  static const String groupmsgTYPEnotificationUserLeft = 'removedleft';
  static const String groupmsgTYPEnotificationSetToAdminOnly = 'settoadminonly';
  static const String groupmsgTYPEnotificationSetToUsersAndAdmin =
      'settousersandadmin';
  static const String groupmsgTYPEaudio = 'audio';
  static const String groupmsgTYPEimage = 'image';
  static const String groupmsgTYPEvideo = 'video';
  static const String groupmsgTYPEdocument = 'document';
  static const String groupmsgTYPElocation = 'location';
  static const String groupmsgTYPElcontact = 'contact';

  //---   All Group Chat Fileds-
  static const String broadcastBLACKLISTED = 'blacklisted';
  static const String broadcastPHOTOURL = 'photourl';
  static const String broadcastNAME = 'name';
  static const String broadcastID = 'id';
  static const String broadcastDESCRIPTION = 'description';
  static const String broadcastMEMBERSLIST = 'memberslist';
  static const String broadcastCREATEDBY = 'createdby';
  static const String broadcastCREATEDON = 'createdon';
  static const String broadcastLATESTMESSAGETIME = 'timestamplatest';
  static const String broadcastADMINLIST = 'adminlist';

  //--
  static const String broadcastmsgCONTENT = 'content';
  static const String broadcastmsgLISToptional = 'list';
  static const String broadcastmsgTIME = 'timestamp';
  static const String broadcastmsgSENDBY = 'sendby';
  static const String broadcastmsgISDELETED = 'isDeleted';
  static const String broadcastmsgTYPE = 'type';
  static const String broadcastmsgISMEDIA = 'ismedia';
  //------
  static const String broadcastmsgTYPEnotificationCreatedbroadcast =
      'createdbroadcast';
  static const String broadcastmsgTYPEnotificationUpdatedbroadcastDetails =
      'updatedbroadcastdetails';
  static const String broadcastmsgTYPEnotificationUpdatedbroadcasticon =
      'updatedbroadcastdetailsicon';
  static const String broadcastmsgTYPEnotificationDeletedbroadcasticon =
      'updatedbroadcastdetailsicon';

  static const String broadcastmsgTYPEnotificationAddedUser = 'addeduser';
  static const String broadcastmsgTYPEnotificationRemovedUser = 'removeduser';

  static const String broadcastmsgTYPEaudio = 'audio';
  static const String broadcastmsgTYPEimage = 'image';
  static const String broadcastmsgTYPEvideo = 'video';
  static const String broadcastmsgTYPEdocument = 'document';
  static const String broadcastmsgTYPElocation = 'location';
  static const String broadcastmsgTYPElcontact = 'contact';

  //---Firebase Indentifiers below
  static const String firebaseStorageNoObjectFound1 = 'object-not-found';
  static const String firebaseStorageNoObjectFound2 = 'does not exist';
  static const String firebaseStorageNoObjectFound3 = 'exists';
  static const String firebaseStorageNoObjectFound4 = 'exist';
  static const String firebaseStorageNoObjectFound5 = 'Not Found';
  static const String firebaseStorageNoObjectFound6 = 'found';
  static const String firebaseStorageNoObjectFound7 = '404';
  static const String firebaseStorageNoObjectFound8 = 'not delete';

  //----All App Constants ----
  static const String timestampField = 'timestamp';
  static const String isTokenGenerated = 'isTokenGenerated';
  static const String notificationTokens = 'notificationTokens';
  static const String photoUrl = 'photoUrl';
  static const String answerTries = 'answerTries';
  static const String passcodeTries = 'passcodeTries';
  static const String aboutMe = 'aboutMe';
  static const String nickname = 'nickname';
  static const String messageType = 'type';
  static const String isMuted = 'isMuted';
  static const String from = 'from';
  static const String to = 'to';
  static const String sendername = 'sname';
  static const String hasRecipientDeleted = 'rd';
  static const String hasSenderDeleted = 'sd';
  static const String content = 'content';
  static const String tempcontent = 'tempcontent';
  static const String chatsWith = 'chatsWith';
  static const String chatStatus = 'chatStatus';
  static const String lastSeen = 'lastSeen';
  static const String lastOnline = 'lastTimeOnline';
  static const String phone = 'phone';
  static const String phoneRaw = 'phone_raw';
  static const String isSecuritySetupDone = 'isd';
  static const String isPINsetDone = 'ipsd';
  static const String id = 'id';
  static const String answer = 'answer';
  static const String question = 'question';
  static const String passcode = 'passcode';
  static const String hidden = 'hidden';
  static const String locked = 'locked';
  static const String deleteUpto = 'deleteUpto';
  static const String timestamp = 'timestamp';
  static const String lastAnswered = 'lastAnswered';
  static const String lastAttempt = 'lastAttempt';
  static const String authenticationType = 'authenticationType';
  static const String cachedContacts = 'cachedContacts';
  static const String saved = 'saved';
  static const String aliasName = 'aliasName';
  static const String aliasAvatar = 'aliasAvatar';
  static const String publicKey = 'publicKey';
  static const String privateKey = 'privateKey';
  static const String countryCode = 'countryCode';
  static const String wallpaper = 'wallpaper';
  static const String crcSeperator = '&';
  static const String currentDeviceID = 'currentDeviceID';
  static const String lastLogin = 'lastLogin';
  static const String joinedOn = 'joinedOn';
  static const String searchKey = 'searchKey';
  static const String groupsCreated = 'groupsCreated';
  static const String blockeduserslist = 'blockeduserslist';
  static const String videoCallMade = 'videoCallMade';
  static const String videoCallRecieved = 'videoCallRecieved';
  static const String audioCallMade = 'audioCallMade';
  static const String audioCallRecieved = 'audioCallRecieved';
  static const String mssgSent = 'mssgSent';
  static const String deviceDetails = 'deviceDetails';
  static const String accountstatus = 'accountstatus';
  static const String actionmessage = 'actionmessage';
  static const String phonenumbervariants = 'phonenumbervariants';
  static const String isbroadcast = 'isbroadcast';
  static const String broadcastLocations = 'broadcastLocations';
  //---
  static const String notificationStringsMap = 'notificationsMap';
  static const String isNotificationStringsMulitilanguageEnabled =
      'isMultiLangNotifEnabled';
  static const String notificationStringNewTextMessage = 'ntm';
  static const String notificationStringNewImageMessage = 'nim';
  static const String notificationStringNewVideoMessage = 'nvm';
  static const String notificationStringNewAudioMessage = 'nam';
  static const String notificationStringNewContactMessage = 'ncm';
  static const String notificationStringNewDocumentMessage = 'ndm';
  static const String notificationStringNewLocationMessage = 'nlm';
  static const String notificationStringNewIncomingAudioCall = 'niac';
  static const String notificationStringNewIncomingVideoCall = 'nivc';
  static const String notificationStringCallEnded = 'ce';
  static const String notificationStringMissedCall = 'mc';
  static const String notificationStringAcceptOrRejectCall = 'aorc';
  static const String notificationStringCallRejected = 'cr';
  //---
  static const int triesThreshold = 3;
  static const int timeBase = 2;
  //--
  static const String datatypeGROUPCHATMSGS = 'groupchatMSGS';
  static const String datatypeBROADCASTCMSGS = 'broadcastMSGS';
  static const String datatypeONETOONEMSGS = 'onetooneMSGS';
  static const String isReply = 'isReply';
  static const String replyToMsgDoc = 'replyToMsgDoc';
  static const String isForward = 'isForward';
  static const String latestEncrypted = 'lE';
  //--
  static const String maxNoOfFilesInMultiSharing = 'maxNoOfFilesInMultiSharing';
  static const String maxNoOfContactsSelectForForward =
      'maxNoOfContactsSelectForForward';
  static const String appShareMessageStringAndroid =
      'appShareMessageStringAndroid';
  static const String appShareMessageStringiOS = 'appShareMessageStringiOS';
  static const String isCustomAppShareLink = 'isCustomAppShareLink';
  //---
  static const String deviceSavedLeads = 'deviceSavedLeads';
  static const String lastupdatedepoch = 'lue';

  // Seng add - task
  static const String taskduedate = 'dueDate';
}

//WARNING: DO NOT EDIT BELOW LINES ON YOUR OWN:
const String K1 = 's1Q0Bj0Edq344U6770i3c556H40';
const String K2 = 'G2P2Fs5ggm218V2265j2';
const String K3 = 'v8u0Uv2xlg547H1764z8l334bz6';
const String K4 = '101';
const String K5 = '30776444';
const String K6 = 'J4tr28z9Ci4856';
const String K7 = 's384tvrhd74fnacs3r92gt3urv';
const String K8 = "Fiberchat";
const String K9 = "appsettings";
const String K11 = 'userapp';
final k12 = FirebaseFirestore.instance
    .collection(Dbkeys.appsettings)
    .doc(Dbkeys.userapp);
const K13 = 'User App';
