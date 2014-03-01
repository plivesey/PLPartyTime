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

@property (nonatomic, readonly, strong) NSString *serviceType;
@property (nonatomic, readonly, strong) NSString *displayName;

- (instancetype)initWithServiceType:(NSString *)serviceType;
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName;

- (void)joinParty;

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
   didReceiveData:(NSData *)data
         fromPeer:(MCPeerID *)peerID;

@optional
- (void)partyTime:(PLPartyTime *)partyTime
  connectedToPeer:(MCPeerID *)peer
     currentPeers:(NSArray *)currentPeers;

@end
