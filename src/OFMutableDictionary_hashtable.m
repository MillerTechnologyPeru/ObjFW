/*
 * Copyright (c) 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017,
 *               2018
 *   Jonathan Schleifer <js@heap.zone>
 *
 * All rights reserved.
 *
 * This file is part of ObjFW. It may be distributed under the terms of the
 * Q Public License 1.0, which can be found in the file LICENSE.QPL included in
 * the packaging of this file.
 *
 * Alternatively, it may be distributed under the terms of the GNU General
 * Public License, either version 2 or 3, which can be found in the file
 * LICENSE.GPLv2 or LICENSE.GPLv3 respectively included in the packaging of this
 * file.
 */

#include "config.h"

#include <string.h>

#import "OFMutableDictionary_hashtable.h"
#import "OFDictionary_hashtable.h"
#import "OFMapTable.h"

#import "OFEnumerationMutationException.h"
#import "OFOutOfRangeException.h"

@implementation OFMutableDictionary_hashtable
+ (void)initialize
{
	if (self == [OFMutableDictionary_hashtable class])
		[self inheritMethodsFromClass: [OFDictionary_hashtable class]];
}

- (void)setObject: (id)object
	   forKey: (id)key
{
	[_mapTable setObject: object
		      forKey: key];
}

- (void)removeObjectForKey: (id)key
{
	[_mapTable removeObjectForKey: key];
}

- (void)removeAllObjects
{
	[_mapTable removeAllObjects];
}

#ifdef OF_HAVE_BLOCKS
- (void)replaceObjectsUsingBlock: (of_dictionary_replace_block_t)block
{
	@try {
		[_mapTable replaceObjectsUsingBlock:
		    ^ void *(void *key, void *object) {
			return block(key, object);
		}];
	} @catch (OFEnumerationMutationException *e) {
		@throw [OFEnumerationMutationException
		    exceptionWithObject: self];
	}
}
#endif

- (void)makeImmutable
{
	object_setClass(self, [OFDictionary_hashtable class]);
}
@end
