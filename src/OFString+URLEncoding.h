/*
 * Copyright (c) 2008, 2009, 2010, 2011, 2012
 *   Jonathan Schleifer <js@webkeks.org>
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

#import "OFString.h"

#ifdef __cplusplus
extern "C" {
#endif
extern int _OFString_URLEncoding_reference;
#ifdef __cplusplus
}
#endif

/*!
 * @brief A category which provides URL encoding and decoding.
 */
@interface OFString (URLEncoding)
/*!
 * @brief Encodes a string for use in a URL.
 *
 * @return A new autoreleased string
 */
- (OFString*)stringByURLEncoding;

/*!
 * @brief Decodes a string used in a URL.
 *
 * @return A new autoreleased string
 */
- (OFString*)stringByURLDecoding;
@end
