--------------------------------------------------------
-- Credits --
--------------------------------------------------------
-- Elv
-- the Tuk/Elv community for making this possible!
-- 
--
--------------------------------------------------------
-- System Settable Variables --
--------------------------------------------------------
local E, L, DF = unpack(ElvUI); --Engine
local DT = E:GetModule('DataTexts')

ElvUI_DTbar = CreateFrame('Frame', 'ElvUI_DTbar', E.UIParent)

local bottom_bar, rchat_tab, rchat_tab2
local PANEL_HEIGHT = 22 -- taken from Layout.lua

db = db or {}
--------------------------------------------------------
-- Language Variables --
--------------------------------------------------------

-- description as shown in /ec -> datatext;  L['panel name'] = 'description';
L['Bottom_Datatext_Panel'] = 'Action Bar 1 (Bottom) Data Panel';
L['RightChatTab_Datatext_Panel'] = 'Upper Right Chat';
L['RightChatTab_Datatext_Panel2'] = 'Upper Right Chat 2';
--------------------------------------------------------


--------------------------------------------------------
-- default values for datatext
--------------------------------------------------------
--Bottom_Datatext_Panel
DF.datatexts.panels.spec1.Bottom_Datatext_Panel = {
	left = 'Friends',
	middle = 'Spec Switch',
	right = 'Guild',
}

DF.datatexts.panels.spec2.Bottom_Datatext_Panel = {
	left = 'Friends',
	middle = 'Spec Switch',
	right = 'Guild',
}

DF.datatexts.panels.spec1.RightChatTab_Datatext_Panel = 'Call to Arms'
DF.datatexts.panels.spec2.RightChatTab_Datatext_Panel = 'Call to Arms'

DF.datatexts.panels.spec1.RightChatTab_Datatext_Panel2 = 'Bags'
DF.datatexts.panels.spec2.RightChatTab_Datatext_Panel2 = 'Bags'

--------------------------------------------------


--------------------------------------------------------
-- Code  --
--------------------------------------------------------

--------------------------------------------------------
 -- right chat tabbar
--------------------------------------------------------
local function rchat_tab_setup()
	do
		rchat_tab:Size(RightChatPanel:GetWidth() /3,PANEL_HEIGHT)
		rchat_tab:Point("RIGHT", RightChatTab_Datatext_Panel2, "LEFT")
		rchat_tab:SetFrameStrata('LOW')

		rchat_tab2:Size((RightChatPanel:GetWidth() / 3),PANEL_HEIGHT)
		rchat_tab2:Point("TOPRIGHT", RightChatTab, "TOPRIGHT", -16, 0) -- if you use the skada embed code you might need to adjust the x-offset to allow room for the arrow button
		rchat_tab2:SetFrameStrata('LOW')

		RightChatTab:HookScript("OnHide", function() 
			rchat_tab:Hide() 
			rchat_tab2:Hide() 
		end)
		RightChatTab:HookScript("OnShow", function() 
			rchat_tab:Show() 
			rchat_tab:SetAlpha(RightChatTab:GetAlpha()) 
			rchat_tab2:Show() 
			rchat_tab2:SetAlpha(RightChatTab:GetAlpha()) 
		end)
	end
end

 do
	rchat_tab = CreateFrame('Frame', 'RightChatTab_Datatext_Panel', E.UIParent)
	rchat_tab.db ={key='RightChatTab_Datatext_Panel', value = true}
	DT:RegisterPanel(rchat_tab, 1, 'ANCHOR_BOTTOM', 0, -4)
	rchat_tab:Hide()
end

--------------------------------------------------------
-- right chat tabbar2
--------------------------------------------------------
 do
	rchat_tab2 = CreateFrame('Frame', 'RightChatTab_Datatext_Panel2', E.UIParent)
	rchat_tab2.db = {key='RightChatTab_Datatext_Panel2', value = true}
	DT:RegisterPanel(rchat_tab2, 1, 'ANCHOR_BOTTOM', 0, -4)
	rchat_tab2:Hide()
end

--------------------------------------------------------
-- bottom bar					
--------------------------------------------------------
do
	bottom_bar = CreateFrame('Frame', 'Bottom_Datatext_Panel', E.UIParent)
	bottom_bar.db = {key ='Bottom_Datatext_Panel', value = true}
	bottom_bar:SetTemplate('Default', true)
	bottom_bar:SetFrameStrata('BACKGROUND')
	bottom_bar:SetScript('OnShow', function(self) 
		self:Point("TOPLEFT", ElvUI_Bar1, "BOTTOMLEFT", 0, -E.mult); 
		self:Size(ElvUI_Bar1:GetWidth(), PANEL_HEIGHT); 
		E:CreateMover(self, "BottomBarMover", "Bottom Datatext Frame") 
	end)
	bottom_bar:Hide()
	DT:RegisterPanel(bottom_bar, 3, 'ANCHOR_BOTTOM', 0, -4)
end


--
-- Table O' Frame tables! we parse and check for GetName() to toggle show/hide :) saves some very nasty lines of code.
--
ElvUI_DTbar._table = {
	bottom_bar,
	rchat_tab,
	rchat_tab2,
}

 local function SlashHandler(command)
	if command == 'show all' then						-- show all
		for k,v in ipairs(ElvUI_DTbar._table) do v:Show() db[v:GetName()] = true end
	elseif command:match("^show .*") then				-- show <bar> --> this line is pure beauty
		command = command:gsub("^show ","")
		for k,v in ipairs(ElvUI_DTbar._table) do if (v:GetName():lower():match(command:lower())) then v:Show() db[v:GetName()] = true end end
	elseif command == 'hide all' then					-- hide all
		for k,v in ipairs(ElvUI_DTbar._table) do v:Hide() db[v:GetName()] = false end
	elseif command:match("^hide .*") then				-- hide <bar>  --> this line is pure beauty
		command = command:gsub("^hide ","")
		for k,v in ipairs(ElvUI_DTbar._table) do if (v:GetName():lower():match(command:lower())) then v:Hide() db[v:GetName()] = false end end
	elseif command == 'list' then						-- list
		for k,v in ipairs(ElvUI_DTbar._table) do print ('Frame: '..v:GetName()) end 
	else							-- syntax
		print ('\
			commands are:\
/dtbar show <frameName>\
/dtbar show all\
/dtbar hide <frameName>\
/dtbar hide all\
/dtbar list\
')
	end	
end

 function ElvUI_DTbar.db_check()

	for k,v in ipairs(ElvUI_DTbar._table) do
		local _name = v.db.key

		if db[_name] == true then
			v:Show()
		elseif db[_name] == false then
		else								--missing entry
			db[_name] = v.db.value
			v:Show()

		end 
	end
end

function DT:PLAYER_ENTERING_WORLD(...)
	SlashCmdList["ElvUI_DTbar"] = SlashHandler
	SLASH_ElvUI_DTbar1 = "/dtbar"

	rchat_tab_setup()
	ElvUI_DTbar.db_check()

	self:UnregisterEvent("PLAYER_ENTERING_WORLD");
end

DT:RegisterEvent('PLAYER_ENTERING_WORLD')
