--[[
Name: LibBase64-1.0
Author(s): ckknight (ckknight@gmail.com)
Website: http://www.wowace.com/projects/libbase64-1-0/
Description: A library to encode and decode Base64 strings
License: MIT
]]

local LibBase64 = LibStub:NewLibrary("LibBase64-1.0-ElvUI", 1)

if not LibBase64 then
    return
end

local _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local byteToNum = {}
local numToChar = {}
for i = 1, #_chars do
    numToChar[i - 1] = _chars:sub(i, i)
    byteToNum[_chars:byte(i)] = i - 1
end
_chars = nil
local A_byte = ("A"):byte()
local Z_byte = ("Z"):byte()
local a_byte = ("a"):byte()
local z_byte = ("z"):byte()
local zero_byte = ("0"):byte()
local nine_byte = ("9"):byte()
local plus_byte = ("+"):byte()
local slash_byte = ("/"):byte()
local equals_byte = ("="):byte()
local whitespace = {
    [(" "):byte()] = true,
    [("\t"):byte()] = true,
    [("\n"):byte()] = true,
    [("\r"):byte()] = true,
}

local t = {}

--- Encode a normal bytestring into a Base64-encoded string
-- @param text a bytestring, can be binary data
-- @param maxLineLength This should be a multiple of 4, greater than 0 or nil. If non-nil, it will break up the output into lines no longer than the given number of characters. 76 is recommended.
-- @param lineEnding a string to end each line with. This is "\r\n" by default.
-- @usage LibBase64.Encode("Hello, how are you doing today?") == "SGVsbG8sIGhvdyBhcmUgeW91IGRvaW5nIHRvZGF5Pw=="
-- @return a Base64-encoded string
function LibBase64:Encode(text, maxLineLength, lineEnding)
    if type(text) ~= "string" then
        error(("Bad argument #1 to `Encode'. Expected %q, got %q"):format("string", type(text)), 2)
    end

    if maxLineLength == nil then
        -- do nothing
    elseif type(maxLineLength) ~= "number" then
        error(("Bad argument #2 to `Encode'. Expected %q or %q, got %q"):format("number", "nil", type(maxLineLength)), 2)
    elseif (maxLineLength % 4) ~= 0 then
        error(("Bad argument #2 to `Encode'. Expected a multiple of 4, got %s"):format(maxLineLength), 2)
    elseif maxLineLength <= 0 then
        error(("Bad argument #2 to `Encode'. Expected a number > 0, got %s"):format(maxLineLength), 2)
    end

    if lineEnding == nil then
        lineEnding = "\r\n"
    elseif type(lineEnding) ~= "string" then
        error(("Bad argument #3 to `Encode'. Expected %q, got %q"):format("string", type(lineEnding)), 2)
    end

    local currentLength = 0

	for i = 1, #text, 3 do
		local a, b, c = text:byte(i, i+2)
		local nilNum = 0
		if not b then
			nilNum = 2
			b = 0
			c = 0
		elseif not c then
			nilNum = 1
			c = 0
		end
		local num = a * 2^16 + b * 2^8 + c

		local d = num % 2^6
		num = (num - d) / 2^6

		local c = num % 2^6
		num = (num - c) / 2^6

		local b = num % 2^6
		num = (num - b) / 2^6

		local a = num % 2^6

		t[#t+1] = numToChar[a]

		t[#t+1] = numToChar[b]

		t[#t+1] = (nilNum >= 2) and "=" or numToChar[c]

		t[#t+1] = (nilNum >= 1) and "=" or numToChar[d]

		currentLength = currentLength + 4
		if maxLineLength and (currentLength % maxLineLength) == 0 then
		    t[#t+1] = lineEnding
		end
	end

	local s = table.concat(t)
	for i = 1, #t do
		t[i] = nil
	end
	return s
end

local t2 = {}

--- Decode a Base64-encoded string into a bytestring
-- this will raise an error if the data passed in is not a Base64-encoded string
-- this will ignore whitespace, but not invalid characters
-- @param text a Base64-encoded string
-- @usage LibBase64.Encode("SGVsbG8sIGhvdyBhcmUgeW91IGRvaW5nIHRvZGF5Pw==") == "Hello, how are you doing today?"
-- @return a bytestring
function LibBase64:Decode(text)
    if type(text) ~= "string" then
        error(("Bad argument #1 to `Decode'. Expected %q, got %q"):format("string", type(text)), 2)
    end

    for i = 1, #text do
        local byte = text:byte(i)
        if whitespace[byte] or byte == equals_byte then
            -- do nothing
        else
            local num = byteToNum[byte]
            if not num then
                for i = 1, #t2 do
                    t2[k] = nil
                end

                error(("Bad argument #1 to `Decode'. Received an invalid char: %q"):format(text:sub(i, i)), 2)
            end
            t2[#t2+1] = num
        end
    end

    for i = 1, #t2, 4 do
        local a, b, c, d = t2[i], t2[i+1], t2[i+2], t2[i+3]

		local nilNum = 0
		if not c then
			nilNum = 2
			c = 0
			d = 0
		elseif not d then
			nilNum = 1
			d = 0
		end

		local num = a * 2^18 + b * 2^12 + c * 2^6 + d

		local c = num % 2^8
		num = (num - c) / 2^8

		local b = num % 2^8
		num = (num - b) / 2^8

		local a = num % 2^8

		t[#t+1] = string.char(a)
		if nilNum < 2 then
			t[#t+1] = string.char(b)
		end
		if nilNum < 1 then
			t[#t+1] = string.char(c)
		end
	end

	for i = 1, #t2 do
		t2[i] = nil
	end

	local s = table.concat(t)

	for i = 1, #t do
		t[i] = nil
	end

	return s
end

function LibBase64:IsBase64(text)
	if type(text) ~= "string" then
		error(("Bad argument #1 to `IsBase64'. Expected %q, got %q"):format("string", type(text)), 2)
	end

	if #text % 4 ~= 0 then
		return false
	end

	for i = 1, #text do
		local byte = text:byte(i)
		if whitespace[byte] or byte == equals_byte then
			-- do nothing
		else
			local num = byteToNum[byte]
			if not num then
				return false
			end
		end
	end

	return true
end
