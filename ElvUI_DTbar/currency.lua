local E, L, DF = unpack(ElvUI); --Engine
local DT = E:GetModule('DataTexts')

local lastPanel
local displayString = "---"
local _hex

local function OnEvent(self, event, ...)
	lastPanel = self
	
	local _text = "---"
	if not _hex then return end
	for i = 1, MAX_WATCHED_TOKENS do
		if i == 1 then 
			displayString = '' 
		end
		local name, count, extraCurrencyType, icon, itemid = GetBackpackCurrencyInfo(i)
		if name and count then
			if(i ~= 1) then _text = " " else _text = "" end
			words = { strsplit(" ", name) }
			for _, word in ipairs(words) do
				_text = _text .. string.sub(word,1,1)
			end
			local str = tostring(_text..": ".._hex..count.."|r")
			displayString = displayString..str
		elseif i == 1 and not name and not count then 
			displayString = tostring(_hex.."---")
		end
	end	
	if self then 
		self.text:SetFormattedText(displayString)
	end
	displayString = "---"

end

local function OnEnter(self)
	DT:SetupTooltip(self)
	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
	GameTooltip:Show()
end

local function ValueColorUpdate(hex, r, g, b)
	_hex = hex
	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc)

	name - name of the datatext (required)
	events - must be a table with string values of event names to register
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
]]
DT:RegisterDatatext('Currency', {"PLAYER_LOGIN"}, OnEvent, nil, nil, OnEnter)

 hooksecurefunc("BackpackTokenFrame_Update", function(...) OnEvent(lastPanel) end )
