//
//  RPKIncrementalStore.h
//  ReposityKit
//
//  Created by Duc Ngo on 6/30/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface RPKIncrementalStore : NSIncrementalStore
+ (NSString*) primaryKeyFieldNameForLocalEntity:(NSEntityDescription*)entity;
@end
