//
//  PLPartyTime.m
//  PLPartyTime
//
//  Created by Peter Livesey on 3/1/14.
//  Copyright (c) 2014 Peter Livesey. All rights reserved.
//

#import "PLPartyTime.h"


@interface PLPartyTime ()

@property (nonatomic, readwrite, strong) NSString *serviceType;
@property (nonatomic, readwrite, strong) NSString *displayName;

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
  
}

#pragma mark - Communicate

- (BOOL)sendData:(NSData *)data
        withMode:(MCSessionSendDataMode)mode
           error:(NSError **)error
{
  return YES;
}

- (BOOL)sendData:(NSData *)data
         toPeers:(NSArray *)peerIDs
        withMode:(MCSessionSendDataMode)mode
           error:(NSError **)error
{
  return YES;
}

@end
