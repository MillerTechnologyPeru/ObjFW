/*
 * Copyright (c) 2008, 2009, 2010, 2011, 2012, 2013, 2014
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

#import "threading.h"

bool
of_thread_new(of_thread_t *thread, id (*function)(id), id data)
{
	*thread = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)function,
	    (__bridge void*)data, 0, NULL);

	return (thread != NULL);
}

bool
of_thread_join(of_thread_t thread)
{
	if (WaitForSingleObject(thread, INFINITE))
		return false;

	CloseHandle(thread);

	return true;
}

bool
of_thread_detach(of_thread_t thread)
{
	/* FIXME */
	return true;
}

void OF_NO_RETURN
of_thread_exit(void)
{
	ExitThread(0);

	OF_UNREACHABLE
}

void
of_once(of_once_t *control, void (*func)(void))
{
	switch (InterlockedCompareExchange(control, 1, 0)) {
	case 0:
		func();
		InterlockedIncrement(control);
		break;
	case 1:
		while (*control == 1)
			Sleep(0);
		break;
	}
}

bool
of_mutex_new(of_mutex_t *mutex)
{
	InitializeCriticalSection(mutex);

	return true;
}

bool
of_mutex_lock(of_mutex_t *mutex)
{
	EnterCriticalSection(mutex);

	return true;
}

bool
of_mutex_trylock(of_mutex_t *mutex)
{
	return TryEnterCriticalSection(mutex);
}

bool
of_mutex_unlock(of_mutex_t *mutex)
{
	LeaveCriticalSection(mutex);

	return true;
}

bool
of_mutex_free(of_mutex_t *mutex)
{
	DeleteCriticalSection(mutex);

	return true;
}

bool
of_condition_new(of_condition_t *condition)
{
	condition->count = 0;

	if ((condition->event = CreateEvent(NULL, FALSE, 0, NULL)) == NULL)
		return false;

	return true;
}

bool
of_condition_signal(of_condition_t *condition)
{
	return SetEvent(condition->event);
}

bool
of_condition_broadcast(of_condition_t *condition)
{
	int i;

	for (i = 0; i < condition->count; i++)
		if (!SetEvent(condition->event))
			return false;

	return true;
}

bool
of_condition_wait(of_condition_t *condition, of_mutex_t *mutex)
{
	if (!of_mutex_unlock(mutex))
		return false;

	of_atomic_int_inc(&condition->count);

	if (WaitForSingleObject(condition->event, INFINITE) != WAIT_OBJECT_0) {
		of_mutex_lock(mutex);
		return false;
	}

	of_atomic_int_dec(&condition->count);

	if (!of_mutex_lock(mutex))
		return false;

	return true;
}

bool
of_condition_timed_wait(of_condition_t *condition, of_mutex_t *mutex,
    of_time_interval_t timeout)
{
	if (!of_mutex_unlock(mutex))
		return false;

	of_atomic_int_inc(&condition->count);

	if (WaitForSingleObject(condition->event, timeout * 1000) !=
	    WAIT_OBJECT_0) {
		of_mutex_lock(mutex);
		return false;
	}

	of_atomic_int_dec(&condition->count);

	if (!of_mutex_lock(mutex))
		return false;

	return true;
}

bool
of_condition_free(of_condition_t *condition)
{
	if (condition->count != 0)
		return false;

	return CloseHandle(condition->event);
}
