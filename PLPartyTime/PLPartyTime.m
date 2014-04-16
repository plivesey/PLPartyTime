//
//  PLPartyTime.m
//  PLPartyTime
//
//  Created by Peter Livesey on 3/1/14.
//  Copyright (c) 2014 Peter Livesey. All rights reserved.
//

#import "PLPartyTime.h"


@interface PLPartyTime () <MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

// Public Properties
@property (nonatomic, readwrite) BOOL connected;
@property (nonatomic, readwrite) BOOL acceptingGuests;
@property (nonatomic, readwrite, strong) NSString *serviceType;
@property (nonatomic, readwrite, strong) NSString *displayName;

@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;

@end

@implementation PLPartyTime

#pragma mark - Life Cycle

- (instancetype)initWithServiceType:(NSString *)serviceType
{
  return [self initWithServiceType:serviceType
                       displayName:[UIDevice currentDevice].name];
}

- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
{
  self = [super init];
  if (self)
  {
    self.serviceType = serviceType;
    self.displayName = displayName;
  }
  return self;
}

- (void)dealloc
{
  // Will clean up the session and browsers properly
  [self leaveParty];
}

#pragma mark - Membership

- (void)joinParty
{
  // If we're already joined, then don't try again. This causes crashes.
  if (!self.acceptingGuests)
  {
    // Simultaneously advertise and browse at the same time
    [self.advertiser startAdvertisingPeer];
    [self.browser startBrowsingForPeers];
    
    self.connected = YES;
    self.acceptingGuests = YES;
  }
}

- (void)stopAcceptingGuests
{
  if (self.acceptingGuests)
  {
    [self.advertiser stopAdvertisingPeer];
    [self.browser stopBrowsingForPeers];
    self.acceptingGuests = NO;
  }
}

- (void)leaveParty
{
  [self stopAcceptingGuests];
  [self.session disconnect];
  // Must nil out these because if we try to reconnect, we need to recreate them
  // Else it fails to connect
  self.session = nil;
  self.peerID = nil;
  self.advertiser = nil;
  self.browser = nil;
  self.connected = NO;
}

#pragma mark - Communicate

- (BOOL)sendData:(NSData *)data
        withMode:(MCSessionSendDataMode)mode
           error:(NSError **)error
{
  return [self.session sendData:data
                        toPeers:self.session.connectedPeers
                       withMode:mode
                          error:error];
}

- (BOOL)sendData:(NSData *)data
         toPeers:(NSArray *)peerIDs
        withMode:(MCSessionSendDataMode)mode
           error:(NSError **)error
{
  return [self.session sendData:data
                        toPeers:peerIDs
                       withMode:mode
                          error:error];
}

- (NSOutputStream *)startStreamWithName:(NSString *)streamName
                                 toPeer:(MCPeerID *)peerID
                                  error:(NSError *__autoreleasing *)error
{
  return [self.session startStreamWithName:streamName
                                    toPeer:peerID
                                     error:error];
}

- (NSProgress *)sendResourceAtURL:(NSURL *)resourceURL
                         withName:(NSString *)resourceName
                           toPeer:(MCPeerID *)peerID
            withCompletionHandler:(void (^)(NSError *error))completionHandler
{
  return [self.session sendResourceAtURL:resourceURL
                                withName:resourceName
                                  toPeer:peerID
                   withCompletionHandler:completionHandler];
}

#pragma mark - Properties

- (NSArray *)connectedPeers
{
  return self.session.connectedPeers;
}

- (MCSession *)session
{
  if (!_session)
  {
    _session = [[MCSession alloc] initWithPeer:self.peerID
                              securityIdentity:nil
                          encryptionPreference:MCEncryptionRequired];
    _session.delegate = self;
  }
  return _session;
}

- (MCPeerID *)peerID
{
  if (!_peerID)
  {
    NSAssert(self.displayName, @"No display name. You must initialize this class using the custom intializers.");
    _peerID = [[MCPeerID alloc] initWithDisplayName:self.displayName];
  }
  return _peerID;
}

- (MCNearbyServiceAdvertiser *)advertiser
{
  if (!_advertiser)
  {
    NSAssert(self.serviceType, @"No service type. You must initialize this class using the custom intializers.");
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID
                                                    discoveryInfo:nil
                                                      serviceType:self.serviceType];
    _advertiser.delegate = self;
  }
  return _advertiser;
}

- (MCNearbyServiceBrowser *)browser
{
  if (!_browser)
  {
    NSAssert(self.serviceType, @"No service type. You must initialize this class using the custom intializers.");
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID
                                                serviceType:self.serviceType];
    _browser.delegate = self;
  }
  return _browser;
}

#pragma mark - Session Delegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate partyTime:self peer:peerID changedState:state currentPeers:self.session.connectedPeers];
  });
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([self.delegate respondsToSelector:@selector(partyTime:didReceiveData:fromPeer:)])
    {
      [self.delegate partyTime:self didReceiveData:data fromPeer:peerID];
    }
  });
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([self.delegate respondsToSelector:@selector(partyTime:didReceiveStream:withName:fromPeer:)])
    {
      [self.delegate partyTime:self didReceiveStream:stream withName:streamName fromPeer:peerID];
    }
  });
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([self.delegate respondsToSelector:@selector(partyTime:didStartReceivingResourceWithName:fromPeer:withProgress:)])
    {
      [self.delegate partyTime:self
didStartReceivingResourceWithName:resourceName
                      fromPeer:peerID
                  withProgress:progress];
    }
  });
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([self.delegate respondsToSelector:@selector(partyTime:didFinishReceivingResourceWithName:fromPeer:atURL:withError:)])
    {
      [self.delegate partyTime:self
didFinishReceivingResourceWithName:resourceName
                      fromPeer:peerID
                         atURL:localURL
                     withError:error];
    }
  });
}

// Required because of an apple bug
- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void(^)(BOOL accept))certificateHandler
{
  certificateHandler(YES);
}

#pragma mark - Advertiser Delegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID
       withContext:(NSData *)context
 invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
  // Only accept invitations with IDs lower than the current host
  // If both people accept invitations, then connections are lost
  // However, this should always be the case since we only send invites in one direction
  if ([peerID.displayName compare:self.peerID.displayName] == NSOrderedDescending)
  {
    invitationHandler(YES, self.session);
  }
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
  [self.delegate partyTime:self failedToJoinParty:error];
}

#pragma mark - Browser Delegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
  // Whenever we find a peer, let's just send them an invitation
  // But only send invites one way
  // TODO: What if display names are the same?
  // TODO: Make timeout configurable
  if ([peerID.displayName compare:self.peerID.displayName] == NSOrderedAscending)
  {
    NSLog(@"Sending invite: Self: %@", self.peerID.displayName);
    [browser invitePeer:peerID
              toSession:self.session
            withContext:nil
                timeout:10];
  }
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
  // Ignore this. We don't need it.
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
  [self.delegate partyTime:self failedToJoinParty:error];
}


@end
