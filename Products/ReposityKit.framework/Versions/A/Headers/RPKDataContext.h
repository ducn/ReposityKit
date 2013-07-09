//
//  RPKDataContext.h
//  ReposityKit
//
//  Created by Duc Ngo on 6/30/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@interface RPKDataContext : NSObject
@property(nonatomic, strong)    NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(nonatomic, strong)    NSManagedObjectModel    *managedObjectModel;
// This context will work on main thread
@property (nonatomic, strong)   NSManagedObjectContext  *mainContext;
// This context will work on private queue's thread
@property (nonatomic, strong)   NSManagedObjectContext  *privateContext;
@end
