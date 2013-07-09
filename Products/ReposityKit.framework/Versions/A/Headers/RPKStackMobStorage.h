//
//  RPKStackMobDataContext.h
//  ReposityKit
//
//  Created by Duc Ngo on 6/29/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackMob.h"
@interface RPKStackMobStorage : NSObject<RPKRemoteStorageProtocol>
@property(nonatomic,strong) SMClient *client;
@property(nonatomic,readonly) SMIncrementalStore *smIncrementalStore;
@end
