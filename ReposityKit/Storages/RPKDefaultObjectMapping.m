//
//  RPKDefaultObjectMapping.m
//  ReposityKit
//
//  Created by Duc Ngo on 7/5/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import "RPKDefaultObjectMapping.h"

@implementation RPKDefaultObjectMapping
- (NSString*) primaryKeyFieldForEntity:(NSEntityDescription*)entity{
    return @"identity";
}
- (void) mapJSON:(NSDictionary *)json toManagedObject:(NSManagedObject*)mo withEntityDescription:(NSEntityDescription*)entityDes{
    
    [[entityDes propertiesByName] enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        id propertyValueFromSerializedDict = [json objectForKey:[key underscore]];
        if (propertyValueFromSerializedDict == [NSNull null]) {
            [mo setValue:nil forKey:key];
        } else if (propertyValueFromSerializedDict) {
            if ([object isKindOfClass:[NSAttributeDescription class]]) {
                [mo setValue:propertyValueFromSerializedDict forKey:key];
            } else if ([(NSRelationshipDescription *)object isToMany]) {

            }
        }
    }];
}
@end
