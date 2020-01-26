 require "cosched.queue"

-- @module scheduler
local scheduler = {}

--[[

Copyright (c) 2015 by Marco Lizza (marco.lizza@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

]]--

--[ _________________________________________ SCHEDULER USAGE EXAMPLE _________________________________________]--
--
--[[

	local scheduler = require "cosched.scheduler"

	function thread1()
		print("Hello I'm thread1...");
		while(true) do
			msg = scheduler.pend();
			print("")
			print("Thread1: received", msg);
		end
	end

	function thread2()
		print("Hello I'm thread2...");
		while(true) do
			scheduler.sleep_ms(5000);
			msg = "Hello from Thread2.";
			print("")
			print("Thread2: posting ", msg);
			scheduler.post(thread1,msg);
		end
	end

	-- This is the real scheduler code:
	scheduler.spawn(thread1,0);
	scheduler.spawn(thread2,1);
	scheduler.setTickPeriod_ms(1000);

	while(true) do
		scheduler.pulse(1);
		--This is the real tick timer:
		sleep_ms(scheduler.getTickPeriod_ms());
	end

]]--

--[ _________________________________________ SCHEDULER LOCAL VARS _________________________________________]--
--
--default tick timer interval in ms:
local TICK_TIMER_INTERVAL_ms = 100;
local _quit = false;
--
-- Any thread's status can be either one of the following values. The typical
-- evolution of a thread can be depicted as follows
--
-- +-------------------------------------------------+
-- |                                         +--> WAITING --+    |
-- +--> READY -----> RUNNING --+                      +--+
--                                           +--> SLEEPING --+
--
local READY = 0    -- suspended, will be resumed at the next update
local RUNNING = 1  -- running, only a single thread at once
local WAITING = 2  -- waiting for a named-event to be signalled
local SLEEPING = 3 -- sleeping 'till the timer elapse
local CHECKING = 4 -- held until a give predicate turns true

-- @variable
--
-- This table is indexed with the coroutine handle and holds the waiting
-- parameters for each entry:
-- priority
-- integer value representing thread priority (lower values
-- indicating higher priorities)
-- status
-- any of the above defined values.
-- value
-- signal identifier, timeout value (in milliseconds), or predicate
-- function.
--
local _pool = {}

--[ ______________________________________ SCHEDULER CONFIGURATION/CONTROL ______________________________________]--
--
-- @function
--
-- Creates a new thread bound to the passed function [procedure]. If passed
-- the [priority] argument indicates the thread priority (higher values
-- means lower priority), otherwhise sets it to zero as a default.
-- The thread is initially suspended and will wake up on the next
-- [scheduler.pulse()] call.
--
function scheduler.spawn(procedure, priority, qsize,...)
  local thread = coroutine.create(procedure)

  _pool[thread] =
  {
	pool_idx = thread,
    procedure = procedure,
    priority = priority or 0, -- if not provided revert to highest
    args = table.pack(...),
    status = READY,
    value = nil,
	queue = Queue.create(qsize),
	listeners_max = 10,
	listeners = {}
  }
  
  -- Naïve priority queue implementation, by re-sorting the table every time
  -- we spawn a new thread. A smarter heap-based implementation, at the moment,
  -- it's not worth the effort.
  table.sort(_pool, function(lhs, rhs) return (lhs.priority < rhs.priority) end)
  print("[CREATED TH: ", thread  ,"]")
end

--
-- @function
--
-- Register the thread bound to 'proc_src' corutine to the listeners queue of the thread bound to 'proc_dst' coroutine.
-- After the registration the listener thread (the one bounf to 'proc_src') is able to listen to messages posted from
-- the 'proc_dst' thread.
--
function scheduler.subscribe(proc_src, proc_dst)
  local _src_thread = nil;
  local _dst_listeners = nil;
  local _dst_free_idx = nil;
  local _dst_max_listners = 0;  
  local _idx = 1;
  
  -- Find the source thread and dest listeners list:
  for _, thread in pairs(_pool) do
		if (thread.procedure == proc_src) then
			_src_thread = thread.pool_idx;		
		elseif (thread.procedure == proc_dst) then
			_dst_max_listners = thread.listeners_max;
			_dst_listeners = thread.listeners;
		end
	
		if ((_src_thread ~= nil) and (_dst_listeners ~= nil)) then
			break;
		end
  end
  
  -- If src thread not found or dest listeners list not found return error -1:
   if ((_src_thread == nil) or (_dst_listeners == nil)) then
		return -1;
   end
 
	--check if src thread is already in listening list:
	while (_idx <= _dst_max_listners) do
		-- If src thread ia already a listener return error -2:
		if (_dst_listeners[_idx] == _src_thread) then
			return -2;
		end
		-- If a free listening entry is found save its index:
		if (_dst_listeners[_idx] == nil) then
			_free_idx = _idx;
		end
		_idx = _idx + 1;
	end
 
	-- If a free listening entry index was saved assign it to src thread end return no error 0:
    if (_free_idx ~= nil) then
		_dst_listeners[_free_idx] = _src_thread;
		return 0;
	end
	
	-- A free listening entry index was not found, return no error -3:
	return -3;
end

--
-- @function
--
-- Set the scheduler tick interval in ms. The same value must be used 
-- as waiting time between a pulse invocation and the following.
--
function scheduler.setTickPeriod_ms(mills)
	if(mills > 0) then
		TICK_TIMER_INTERVAL_ms = mills;
	end
end

--
-- @function
--
-- Get the scheduler tick interval in ms. This value must be used 
-- as waiting time between a pulse invocation and the following one.
function scheduler.getTickPeriod_ms()
	return TICK_TIMER_INTERVAL_ms;
end

--
-- @function
--
-- Update the thread list considering [ticks] units have passed. Any
-- sleeping thread whose timeout is elapsed will be woken up.
--
function scheduler.pulse(ticks)
  -- First we need to traverse the table, updating the sleeping threads'
  -- timeout and build the list of the ones to be woken up. We are creating
  -- a one-time snapshot in order to be avoid starvation as much as possible.
  if(_quit == true) then
	return true;
  end
  
  local ready_to_resume = {}

  for thread, params in pairs(_pool) do
    -- Dead threads are detected and removed the from the table itself
    -- (and the garbage-collector will eventually handle them).
    local status = coroutine.status(thread)
    if status == "dead" then
      -- Get rid of the not longer alive thread. We are safe in removing the
      -- entry while iterating with [pairs()] since we are setting the
      -- cell to [nil].
      _pool[thread] = nil
    elseif status == "suspended" then
      -- First we need to update the [SLEEPING] threads' timers.
      if params.status == SLEEPING then
        params.value = params.value - ticks
        -- If the timer has elapsed we switch the thread in [READY] state.
        if params.value <= 0 then
          params.status = READY
          params.value = nil
        end
      -- We also try and see if some [CHECKING] threads need to awaken.
      elseif params.status == CHECKING then
        if params.value() then
          params.status = READY
          params.value = nil
        end
      end
      -- If the thread was already in the [READY] state or its timer
      -- just elapsed, queue it in the list.
      if params.status == READY then
          table.insert(ready_to_resume, thread)
      end
    end
  end

  -- Traverse and wake the ready threads, one at a time.
  -- Please note that if a higher priority thread will switch to
  -- ready state as a side-effect of the following loop it won't
  -- be called until the next [scheduler.pulse()] call.
  for _, thread in ipairs(ready_to_resume) do
    local params = _pool[thread]
    params.status = RUNNING
    coroutine.resume(thread, table.unpack(params.args))
  end
end

--
-- @function
--
-- Dump the current state of the scheduler:
--
function scheduler.dump()
  for thread, params in pairs(_pool) do
    print(thread)
    print(string.format("  %d %d %s", params.priority, params.status, coroutine.status(thread)))
  end
end

--
-- @function
--
-- Execute a scheduling step after the user inputs an enter key.
-- Useful for scheduling debug purpose. It must be called between
-- a pulse invocation and the following one.
function scheduler.step()
  io.stdin:read'*l'
end

function scheduler.quit()
	_quit = true;
end

--[ ______________________________________ THREAD SYNCHRONIZATION API ______________________________________]--
--
-- @function
--
-- Suspends the calling thread execution. It will be resumed on the next
-- [scheduler.pulse()] call, according the its relative priority.
--
function scheduler.yield(...)
  local thread = coroutine.running()

  local params = _pool[thread]
  params.status = READY
  params.value = nil

  return coroutine.yield(...)
end

--
-- @function
--
-- Suspend the calling thread execution for a give amount of [mills].
-- Once the timeout is elapsed, the thread will move to [READY] state
-- and will be scheduled in the following [scheduler.pulse()] call.
--
function scheduler.sleep_ms(mills, ...)
  local thread = coroutine.running()

  local params = _pool[thread]
  params.status = SLEEPING
  params.value = math.floor(mills/TICK_TIMER_INTERVAL_ms)
  --print("["..  params.value .."]")
  return coroutine.yield(...)
end

--
-- @function
--
-- Suspend the calling thread execution for a give amount of [ticks].
-- Once the timeout is elapsed, the thread will move to [READY] state
-- and will be scheduled in the following [scheduler.pulse()] call.
--
function scheduler.sleep_ts(ticks, ...)
  local thread = coroutine.running()

  local params = _pool[thread]
  params.status = SLEEPING
  params.value = ticks

  return coroutine.yield(...)
end

--
-- @function
--
-- Suspend the calling thread execution until the given [predicate]
-- turns true. Once this happens, the thread will move to [READY] state
-- and will be scheduled in the following [scheduler.pulse()] call.
--
function scheduler.check(predicate, ...)
  local thread = coroutine.running()

  local params = _pool[thread]
  params.status = CHECKING
  params.value = predicate

  return coroutine.yield(...)
end

--
-- @function
--
-- Suspend the calling thread execution until a massage is posted into the queue or return
-- immediately popping the first msg from the queue.
--
function scheduler.pend()
  local thread = coroutine.running();
  local params = _pool[thread];
  if(params.queue:getLevel()==0) then
	params.status = WAITING;
	coroutine.yield();
  end
  
  return params.queue:popFirst();
  
end

--
-- @function
--
-- Publish a message to all registered procedure. All waiting threads are
-- marked as "ready" and will wake on the next [scheduler.pulse()] call.
--
function scheduler.publish(msg)
  local thread = coroutine.running();
  local _listeners = _pool[thread].listeners;
  local _max_listners = _pool[thread].listeners_max;  
  local _idx = 1;
  
  	--post this massage to listening threads:
	while (_idx <= _max_listners) do
		if (_listeners[_idx] ~= nil) then
			_pool[_listeners[_idx]].queue:pushLast(msg);
			if (_pool[_listeners[_idx]].status == WAITING) then
				_pool[_listeners[_idx]].status = READY;
			end
		end
		_idx = _idx + 1;
	end
end

--
-- @function
--
-- Post a message to the specified procedure. The waiting thread is
-- marked as "ready" and will wake on the next [scheduler.pulse()] call.
--
function scheduler.post(proc_dst, msg)
  -- Find the dest thread:
  for _, thread in pairs(_pool) do
		if (thread.procedure == proc_dst) then
			thread.queue:pushLast(msg);
			if (thread.status == WAITING) then
				thread.status = READY;
			end
			break;
		end
  end
end

return scheduler