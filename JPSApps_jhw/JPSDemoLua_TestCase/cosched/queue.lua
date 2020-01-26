-- [poplast] to use list as lifo;
-- [pushlast, popfirst] to use list as fifo;

Queue = {};
Queue.__index = Queue;

function Queue.create(size)
	local _q = {};
	setmetatable(_q,Queue);
	_q.size = size;
	_q.first = 0;
	_q.last = 0;
	_q.buffer = {};
	--print("[Queue.create: ", _q.buffer, "", _q.first, _q.last,"]")
	return _q;
end

function Queue:getLevel()
	local last = self.last;
	if(self.last<self.first) then
		last = self.last + self.size;
	end
		
    return (last - self.first);
 end

function Queue:isFull()
  if(self:getLevel() == self.size) then
    return true;
  end
  return false;
 end
 
 function Queue:isEmpty()
  if(self:getLevel() == 0) then
    return true;
  end
  return false;
 end

function Queue:pushLast (value)
	if(self:isFull()) then
		return -1;
	end
	self.buffer[self.last] = value;
	self.last = (self.last +1);
	if(self.last >= self.size) then
		self.last = 0;
	end
	--print("[Queue:pushLast: ", self.buffer, "", self.first, self.last,"]")
	return 0;
end

function Queue:popLast ()
 	if(self:isEmpty()) then
		return nil;
	end
	self.last = self.last-1;
	if(self.last < 0) then
		self.last = self.size;
	end
	value = self.buffer[self.last];
	--print("[Queue:pushLast: ", self.buffer, "", self.first, self.last,"]")
  return value
end

function Queue:pushFirst (value)
	if(self:isFull()) then
		return -1;
	end
	self.first = self.first-1;
	if(self.first < 0) then
		self.first = self.size;
	end
	self.buffer[self.first] = value;
	--print("[Queue:pushFirst: ", self.buffer, "", self.first, self.last,"]")
	return 0;
end

function Queue:popFirst ()
 	if(self:isEmpty()) then
		return nil;
	end
	value = self.buffer[self.first];
	self.first = (self.first +1);
	if(self.first >= self.size) then
		self.first = 0;
	end
	--print("[Queue:popFirst: ", self.buffer, "", self.first, self.last,"]")
  return value
end
 