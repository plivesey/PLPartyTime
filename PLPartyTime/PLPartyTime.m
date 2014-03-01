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
@property (nonatomic, readwrite, strong) NSString *serviceType;
@property (nonatomic, readwrite, strong) NSString *displayName;

@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;

@end

@implementation PLPartyTime

#pragma mark - Initialization

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

#pragma mark - Join

- (void)joinParty
{
  // Simultaneously advertise and browse at the same time
  // We're going to accept all connections on both
  [self.advertiser startAdvertisingPeer];
  [self.browser startBrowsingForPeers];
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

#pragma mark - Properties

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
    NSAssert(self.serviceType, @"No service type`. You must initialize this class using the custom intializers.");
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
    NSAssert(self.serviceType, @"No service type`. You must initialize this class using the custom intializers.");
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
    if (state == MCSessionStateConnected &&
        [self.delegate respondsToSelector:@selector(partyTime:connectedToPeer:currentPeers:)])
    {
      [self.delegate partyTime:self connectedToPeer:peerID currentPeers:self.session.connectedPeers];
    }
  });
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate partyTime:self didReceiveData:data fromPeer:peerID];
  });
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
  
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
  
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
  
}

// Required because of an apple bug
- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void(^)(BOOL accept))certificateHandler
{
  certificateHandler(YES);
}

#pragma mark - Advertiser Delegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
  // Just immediately accept all incoming invitations
  invitationHandler(YES, self.session);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
  // TODO: Handle the error
}

#pragma mark - Browser Delegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
  // Whenever we find a peer, let's just send them an invitation
  // TODO: Make timeout configurable
  [browser invitePeer:peerID
            toSession:self.session
          withContext:nil
              timeout:10];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
  
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
  
}


@end
