--[[
Name: LibBase64-1.0
Author(s): ckknight (ckknight@gmail.com)
Website: http://www.wowace.com/projects/libbase64-1-0/
Description: A library to encode and decode Base64 strings
License: MIT
]]

local MAJOR, MINOR = 'LibBase64-1.0-ElvUI', 2
local LibBase64 = LibStub:NewLibrary(MAJOR, MINOR)
if not LibBase64 then return end

local wipe, type, error, format, strsub, strchar, strbyte, tconcat = wipe, type, error, format, strsub, strchar, strbyte, table.concat
local _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local byteToNum, numToChar = {}, {}
for i = 1, #_chars do
	numToChar[i - 1] = strsub(_chars, i, i)
	byteToNum[strbyte(_chars, i)] = i - 1
end

local t = {}
local equals_byte = strbyte("=")
local whitespace = {
	[strbyte(" ")] = true,
	[strbyte("\t")] = true,
	[strbyte("\n")] = true,
	[strbyte("\r")] = true,
}

--- Encode a normal bytestring into a Base64-encoded string
-- @param text a bytestring, can be binary data
-- @param maxLineLength This should be a multiple of 4, greater than 0 or nil. If non-nil, it will break up the output into lines no longer than the given number of characters. 76 is recommended.
-- @param lineEnding a string to end each line with. This is "\r\n" by default.
-- @usage LibBase64.Encode("Hello, how are you doing today?") == "SGVsbG8sIGhvdyBhcmUgeW91IGRvaW5nIHRvZGF5Pw=="
-- @return a Base64-encoded string
function LibBase64:Encode(text, maxLineLength, lineEnding)
	if type(text) ~= "string" then
		error(format("Bad argument #1 to `Encode'. Expected string, got %q", type(text)), 2)
	end

	if maxLineLength then
		if type(maxLineLength) ~= "number" then
			error(format("Bad argument #2 to `Encode'. Expected number or nil, got %q", type(maxLineLength)), 2)
		elseif (maxLineLength % 4) ~= 0 then
			error(format("Bad argument #2 to `Encode'. Expected a multiple of 4, got %s", maxLineLength), 2)
		elseif maxLineLength <= 0 then
			error(format("Bad argument #2 to `Encode'. Expected a number > 0, got %s", maxLineLength), 2)
		end
	end

	if lineEnding == nil then
		lineEnding = "\r\n"
	elseif type(lineEnding) ~= "string" then
		error(format("Bad argument #3 to `Encode'. Expected string, got %q", type(lineEnding)), 2)
	end

	local currentLength = 0
	for i = 1, #text, 3 do
		local a, b, c = strbyte(text, i, i+2)
		local nilNum = 0
		if not b then
			nilNum, b, c = 2, 0, 0
		elseif not c then
			nilNum, c = 1, 0
		end

		local num = a * 2^16 + b * 2^8 + c
		local d = num % 2^6;num = (num - d) / 2^6
		c = num % 2^6;num = (num - c) / 2^6
		b = num % 2^6;num = (num - b) / 2^6
		a = num % 2^6

		t[#t+1] = numToChar[a]
		t[#t+1] = numToChar[b]
		t[#t+1] = (nilNum >= 2) and "=" or numToChar[c]
		t[#t+1] = (nilNum >= 1) and "=" or numToChar[d]

		currentLength = currentLength + 4
		if maxLineLength and (currentLength % maxLineLength) == 0 then
			t[#t+1] = lineEnding
		end
	end

	local s = tconcat(t)
	wipe(t)

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
		error(format("Bad argument #1 to `Decode'. Expected string, got %q", type(text)), 2)
	end

	for i = 1, #text do
		local byte = strbyte(text, i)
		if not (whitespace[byte] or byte == equals_byte) then
			local num = byteToNum[byte]
			if not num then
				wipe(t2)

				error(format("Bad argument #1 to `Decode'. Received an invalid char: %q", strsub(text, i, i)), 2)
			end

			t2[#t2+1] = num
		end
	end

	for i = 1, #t2, 4 do
		local a, b, c, d = t2[i], t2[i+1], t2[i+2], t2[i+3]
		local nilNum = 0
		if not c then
			nilNum, c, d = 2, 0, 0
		elseif not d then
			nilNum, d = 1, 0
		end

		local num = a * 2^18 + b * 2^12 + c * 2^6 + d
		c = num % 2^8;num = (num - c) / 2^8
		b = num % 2^8;num = (num - b) / 2^8
		a = num % 2^8

		t[#t+1] = strchar(a)
		if nilNum < 2 then t[#t+1] = strchar(b) end
		if nilNum < 1 then t[#t+1] = strchar(c) end
	end

	wipe(t2)

	local s = tconcat(t)
	wipe(t)

	return s
end

function LibBase64:IsBase64(text)
	if type(text) ~= "string" then
		error(format("Bad argument #1 to `IsBase64'. Expected string, got %q", type(text)), 2)
	end

	if #text % 4 ~= 0 then
		return false
	end

	for i = 1, #text do
		local byte = strbyte(text, i)
		if not (whitespace[byte] or byte == equals_byte) then
			local num = byteToNum[byte]
			if not num then
				return false
			end
		end
	end

	return true
end
