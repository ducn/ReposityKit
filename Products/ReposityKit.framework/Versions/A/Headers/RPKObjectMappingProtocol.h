//
//  RPKObjectMappingProtocol.h
//  ReposityKit
//
//  Created by Duc Ngo on 7/4/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol RPKObjectMappingProtocol

// This should return ID field name from server for given entity
- (NSString*) primaryKeyFieldForEntity:(NSEntityDescription*)entity;
- (void) mapJSON:(NSDictionary *)json toManagedObject:(NSManagedObject*)mo withEntityDescription:(NSEntityDescription*)entityDes;

@end
