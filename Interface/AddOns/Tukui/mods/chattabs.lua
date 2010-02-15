if not TukuiChat == true or IsAddOnLoaded("Prat") or IsAddOnLoaded("Chatter") then return end

local event = CreateFrame"Frame"
local dummy = function() end
local inherit = GameFontNormalSmall

local updateFS = function(self, inc, flags, ...)
	if(self.GetFontString) then
		self = self:GetFontString()
	else
		self = self:GetParent():GetFontString()
	end

	local font, fontSize = inherit:GetFont()
	if(inc) then
		self:SetFont(font, fontSize + 1, flags)
	else
		self:SetFont(font, fontSize, flags)
	end

	if((...)) then
		self:SetTextColor(...)
	end
end

local OnEnter = function(self)
	local emphasis = _G["ChatFrame"..self:GetID()..'TabFlash']:IsShown()
	updateFS(self, emphasis, 'OUTLINE', 1, 1, 1)
end

local OnLeave = function(self)
	local r, g, b, a
	local id = self:GetID()
	local emphasis = _G["ChatFrame"..id..'TabFlash']:IsShown()

	if (_G["ChatFrame"..id] == SELECTED_CHAT_FRAME) then
		r, g, b, a = .64, .207, .933, 0
	elseif emphasis then
		r, g, b, a = 1, 0, 0, 0
	else
		r, g, b, a = 1, 1, 1, 0
	end

	updateFS(self, emphasis, nil, r, g, b, a)
end

local OnShow = function(self)
	updateFS(self, true, nil, 1, 0, 0)
end

local OnHide = function(self)
	updateFS(self, nil, nil, 1, 1, 1)
end

local rollCF = function()
	for i = 1, 7 do
		local chat = _G["ChatFrame"..i]
		local tab = _G["ChatFrame"..i.."Tab"]
		local flash = _G["ChatFrame"..i.."TabFlash"]

		flash:GetRegions():SetTexture(nil)
		flash:SetScript("OnShow", OnShow)
		flash:SetScript("OnHide", OnHide)

		_G["ChatFrame"..i.."TabLeft"]:Hide()
		_G["ChatFrame"..i.."TabMiddle"]:Hide()
		_G["ChatFrame"..i.."TabRight"]:Hide()

		tab:SetScript("OnEnter", OnEnter)
		tab:SetScript("OnLeave", OnLeave)

		tab.SetAlpha = dummy
		if(chat == SELECTED_CHAT_FRAME) then
			updateFS(tab, nil, nil, .64, .207, .933, 0)
		else
			updateFS(tab, nil, nil, 1, 1, 1, 0)
		end
		tab:GetHighlightTexture():SetTexture(nil)

		if(chat.isDocked) then
			tab:Show()
			tab.Hide = dummy
		else
			tab.SetAlpha = nil
			tab.Hide = nil
		end
	end
end

event.PLAYER_LOGIN = function()
	rollCF()
	hooksecurefunc("FCF_OpenNewWindow", rollCF)
	hooksecurefunc("FCF_Close", function(self, fallback)
		local frame = fallback or self
		UIParent.Hide(_G[frame:GetName().."Tab"])
	end)

	local _orig_FCF_Tab_OnClick = FCF_Tab_OnClick
	FCF_Tab_OnClick = function(...)
		_orig_FCF_Tab_OnClick(...)

		for k, v in pairs(DOCKED_CHAT_FRAMES) do
			local tab = _G[v:GetName() .. 'Tab']
			local flash = _G[v:GetName() .. 'TabFlash']
			if(v == SELECTED_CHAT_FRAME) then
				updateFS(tab, nil, nil, .64, .207, .933, 0)
			elseif(flash:IsShown()) then
				updateFS(tab, true, nil, 1, 0, 0, 0)
			else
				updateFS(tab, nil, nil, 1, 1, 1, 0)
			end
		end
	end

	FCF_ChatTabFadeFinished = dummy
end

event:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)
event:RegisterEvent"PLAYER_LOGIN"
