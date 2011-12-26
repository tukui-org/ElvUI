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

Broker = CreateFrame('Frame', 'Broker', E.UIParent)
Broker.ldb = LibStub:GetLibrary("LibDataBroker-1.1")
pluginObjects = {}

ElvUI_DTbar = CreateFrame('Frame', 'ElvUI_DTbar', E.UIParent)
ElvUI_DTbar.version = '2.1b'

local bottom_bar, rchat_tab, rchat_tab2
local PANEL_HEIGHT = 22 -- taken from Layout.lua

db = db or {}

-------------
---  LDB  ---
-------------
-- Use 'LDB_name', format here.  if unsure do a /dtbar showldb in game.  CASE SENSITIVE
-------------

DTBar_ldb = {
	'Scrooge',
	'Skada',
	'AtlasLoot',
}
-------------
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
	elseif command == 'showldb' then
		for name, obj in Broker.ldb:DataObjectIterator() do
			print(name)
		end
	elseif command == 'ver' then
		print (ElvUI_DTbar.version)
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

	for name, obj in Broker.ldb:DataObjectIterator() do
		if obj.OnCreate then obj.OnCreate(obj, Frame) end
		pluginObject[name] = obj
	end
	
	-- this is 'pass #2' here we setup call back functions for whatever ldb's we have listed.
	-- problem is we can't reg the callback's on pass #1 because not all of the ldb's are loaded at that tiem.
	for k,v in ipairs(DTBar_ldb) do
		local textUpdate = function(_, name, _, data)
			if Broker.ldb[v] and Broker.ldb[v].Update then
				pluginObjects[v] = data
				Broker.ldb[v].Update(data)
			end
		end
		
		local ValueUpdate = function(_, name, _, data, obj)
			if Broker.ldb[v] then 
				pluginObjects[v] = data
			end
		end
		
		print ('LDB registered call back: '..v)
		Broker.ldb.RegisterCallback(Broker, "LibDataBroker_AttributeChanged_"..v.."_text", textUpdate)
		Broker.ldb.RegisterCallback(Broker, "LibDataBroker_AttributeChanged_"..v.."_value", ValueUpdate)
	end

	self:UnregisterEvent("PLAYER_ENTERING_WORLD");
end

Broker:SetScript("OnEvent", function(_, event, ...) Broker[event](Broker, ...) end)

local _self = {}  --local table to discover WTF we are.

pluginObject = pluginObject or {}

local Frame = CreateFrame('Frame', 'ldb frame', E.UIParent)
	Frame:EnableMouse(true)
	Frame:SetBackdropColor(0,0,0,0) 
--	Frame:SetFrameStrata('BACKGROUND')
--	Frame:SetFrameLevel(3)
--	Frame:Size(400, PANEL_HEIGHT)
--	Frame:Point("CENTER", E.UIParent, "CENTER", 0, -E.mult);
--	Frame:SetTemplate()
	Frame:Hide()

Broker.ldb.frame = Frame
Broker.ldb.obj = pluginObject

	
-- this is 'pass #1', initial pass that registers the datatext.  Problem here is we do not know what ldb's we are working wtih.
-- dynamic register datatext ;) --==> ## SavedVariables: DTBar_ldb
for k,v in ipairs(DTBar_ldb) do
	Broker.ldb[v] = Broker.ldb[v] or {
		OnEvent = function (self, event, ...)
		_self[v] = self
			if self and self.text then 
				self.text:SetText(pluginObjects[v] or v)
			end	
		end,

		Update = function (t)
			if _self[v] and _self[v].text then 
				_self[v].text:SetText(pluginObjects[v])
			end
		end,
		
		Click = function (self, button)
			if pluginObject[v].OnClick then
				pluginObject[v].OnClick(Frame, button)
			end
		end,

		OnEnter = function (self)
			_self[v] = self
			DT:SetupTooltip(self)
			------------------
			if not InCombatLockdown() and not E.db.tooltip.combathide then
				local obj = pluginObject[v]

				if (type(obj.OnLeave) == 'function') then
					self:SetScript("OnLeave", function () GameTooltip:Hide() if obj.OnLeave then obj.OnLeave(frame) end end)						
				end

				if not Frame.isMoving and obj.OnTooltipShow then
					Broker.ldb.debug1 = pluginObject[v]
					Broker.ldb.debug2 = self
					Broker.ldb.debug3 = Frame
					GameTooltip:SetOwner(E.UIParent, "ANCHOR_NONE")
					GameTooltip:ClearAllPoints()
					GameTooltip:SetPoint("BOTTOM", Frame, "TOP", 0, E.mult)
					GameTooltip:ClearLines()	
					obj.OnTooltipShow(GameTooltip, Frame)
					GameTooltip:Show()
					
					
				elseif obj.OnEnter then
					Frame:Size( self:GetWidth(), self:GetHeight() )
					Frame:Point("TOPLEFT",self, "TOPLEFT")
					Frame:Point("BOTTOMRIGHT",self, "BOTTOMRIGHT")					

					obj.OnEnter(Frame)
				end
			end	
			------------------
			GameTooltip:Show()
		end,
		----
	}
	print ('LDB registered Datatext: '..v)
	DT:RegisterDatatext('LDB_'..v, {}, Broker.ldb[v].OnEvent, Broker.ldb[v].Update, Broker.ldb[v].Click, Broker.ldb[v].OnEnter)
end


DT:RegisterEvent('PLAYER_ENTERING_WORLD')
