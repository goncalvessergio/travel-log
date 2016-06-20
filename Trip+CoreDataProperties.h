//
//  Trip+CoreDataProperties.h
//  Travel Log
//
//  Created by CapitanBanana on 26/05/16.
//  Copyright © 2016 CapitanBanana. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Trip.h"

NS_ASSUME_NONNULL_BEGIN

@interface Trip (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *details;
@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *diary_entries;

@end

@interface Trip (CoreDataGeneratedAccessors)

- (void)addDiary_entriesObject:(NSManagedObject *)value;
- (void)removeDiary_entriesObject:(NSManagedObject *)value;
- (void)addDiary_entries:(NSSet<NSManagedObject *> *)values;
- (void)removeDiary_entries:(NSSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END
