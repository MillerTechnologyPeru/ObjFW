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

#import "OFASN1Value.h"

OF_ASSUME_NONNULL_BEGIN

@class OFString;

/*!
 * @brief An ASN.1 UTF-8 string.
 */
@interface OFASN1UTF8String: OFASN1Value
{
	OFString *_UTF8StringValue;
}

/*!
 * @brief The UTF-8 string value.
 */
@property (readonly, nonatomic) OFString *UTF8StringValue;

/*!
 * @brief The string value.
 */
@property (readonly, nonatomic) OFString *stringValue;
@end

OF_ASSUME_NONNULL_END
