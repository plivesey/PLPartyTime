//
//  PLPartyTime.h
//  PLPartyTime
//
//  Created by Peter Livesey on 3/1/14.
//  Copyright (c) 2014 Peter Livesey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>


@protocol PLPartyTimeDelegate;

@interface PLPartyTime : NSObject

@property (nonatomic, weak) id<PLPartyTimeDelegate> delegate;

@property (nonatomic, readonly) BOOL connected;
@property (nonatomic, readonly) NSArray *connectedPeers;
@property (nonatomic, readonly, strong) NSString *serviceType;
@property (nonatomic, readonly, strong) NSString *displayName;

- (instancetype)initWithServiceType:(NSString *)serviceType;
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName;

- (void)joinParty;
- (void)leaveParty;

- (BOOL)sendData:(NSData *)data
        withMode:(MCSessionSendDataMode)mode
           error:(NSError **)error;
- (BOOL)sendData:(NSData *)data
         toPeers:(NSArray *)peerIDs
        withMode:(MCSessionSendDataMode)mode
           error:(NSError **)error;

@end

@protocol PLPartyTimeDelegate <NSObject>

@required
- (void)partyTime:(PLPartyTime *)partyTime
             peer:(MCPeerID *)peer
     changedState:(MCSessionState)state
     currentPeers:(NSArray *)currentPeers;

@optional
- (void)partyTime:(PLPartyTime *)partyTime
   didReceiveData:(NSData *)data
         fromPeer:(MCPeerID *)peerID;

- (void)partyTime:(PLPartyTime *)partyTime
 didReceiveStream:(NSInputStream *)stream
         withName:(NSString *)streamName
         fromPeer:(MCPeerID *)peerID;

- (void)partyTime:(PLPartyTime *)partyTime
didStartReceivingResourceWithName:(NSString *)resourceName
         fromPeer:(MCPeerID *)peerID
     withProgress:(NSProgress *)progress;

- (void)partyTime:(PLPartyTime *)partyTime
didFinishReceivingResourceWithName:(NSString *)resourceName
         fromPeer:(MCPeerID *)peerID
            atURL:(NSURL *)localURL
        withError:(NSError *)error;

@end
