--------------------------------------------------------------------
 -- CURRENCY
--------------------------------------------------------------------

if TukuiCF["datatext"].currency and TukuiCF["datatext"].currency > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("MEDIUM")
	Stat:SetFrameLevel(3)

	local Text  = TukuiInfoLeft:CreateFontString(nil, "OVERLAY")
	Text:SetFont(TukuiCF.media.font, TukuiCF["datatext"].fontsize, "THINOUTLINE")
	Text:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)
	TukuiDB.PP(TukuiCF["datatext"].currency, Text)
	
	local function update()
		local _text = "---"
		for i = 1, MAX_WATCHED_TOKENS do
			local name, count, _, _, _ = GetBackpackCurrencyInfo(i)
			if name and count then
				if(i ~= 1) then _text = _text .. " " else _text = "" end
				words = { strsplit(" ", name) }
				for _, word in ipairs(words) do
					_text = _text .. string.sub(word,1,1)
				end
				_text = _text .. ": " .. valuecolor.. count .." |r"
			end
		end
		
		Text:SetText(_text)
	end
	
	local function OnEvent(self, event, ...)
		update()
		self:SetAllPoints(Text)
		Stat:UnregisterEvent("PLAYER_LOGIN")	
	end

	Stat:RegisterEvent("PLAYER_LOGIN")	
	hooksecurefunc("BackpackTokenFrame_Update", update)
	Stat:SetScript("OnEvent", OnEvent)
	Stat:SetScript("OnMouseDown", function() ToggleCharacter("TokenFrame") end)
end