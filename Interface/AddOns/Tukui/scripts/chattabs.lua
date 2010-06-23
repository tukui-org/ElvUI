if TukuiDB["chat"].enable ~= true then return end

-----------------------------------------------------------------------
-- OVERWRITE GLOBAL VAR FROM BLIZZARD
-----------------------------------------------------------------------

-- seconds to wait when chatframe fade, default is 2
CHAT_FRAME_FADE_OUT_TIME = 0

-- seconds to wait when tabs are not on mouseover, default is 1
CHAT_TAB_HIDE_DELAY = 0

-- alpha of the current tab, default in 3.3.5 are 1 for mouseover and 0.4 for nomouseover
CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0

-- alpha of non-selected and non-alert tabs, defaut on mouseover is 0.6 and on nomouseover, 0.2
CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0

-- alpha of alerts (example: whisper via another tab)
CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 0

-----------------------------------------------------------------------
-- Tabs script begin ...
-----------------------------------------------------------------------

local event = CreateFrame"Frame"

function TukuiDB.TabsMouseover()
	for i = 1, NUM_CHAT_WINDOWS do
		local chat = _G["ChatFrame"..i]
		local tab = _G["ChatFrame"..i.."Tab"]
		local editBox = _G["ChatFrame"..i.."EditBox"]

		tab.noMouseAlpha = 0
				
		-- non-docked chat tabs is semi-transparent on login, need to set alpha to 0.
		if chat.isDocked ~= 1 then
			tab:SetAlpha(0)
		end
			
		-- tab texture hiding
		_G["ChatFrame"..i.."TabLeft"]:SetTexture(nil)
		_G["ChatFrame"..i.."TabMiddle"]:SetTexture(nil)
		_G["ChatFrame"..i.."TabRight"]:SetTexture(nil)
		
		_G["ChatFrame"..i.."TabSelectedMiddle"]:SetTexture(nil)
		_G["ChatFrame"..i.."TabSelectedRight"]:SetTexture(nil)
		_G["ChatFrame"..i.."TabSelectedLeft"]:SetTexture(nil)
		
		_G["ChatFrame"..i.."TabHighlightLeft"]:SetTexture(nil)
		_G["ChatFrame"..i.."TabHighlightRight"]:SetTexture(nil)
		_G["ChatFrame"..i.."TabHighlightMiddle"]:SetTexture(nil)
	end
end

event.PLAYER_LOGIN = function()
	TukuiDB.TabsMouseover()
end

event:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)
event:RegisterEvent"PLAYER_LOGIN"
