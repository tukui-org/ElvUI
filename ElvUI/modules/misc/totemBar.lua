local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TOTEMS = E:NewModule('Totems', 'AceEvent-3.0');
E.TotemBar = TOTEMS

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local CreateFrame = CreateFrame
local GetTotemInfo = GetTotemInfo
local CooldownFrame_SetTimer = CooldownFrame_SetTimer
local MAX_TOTEMS = MAX_TOTEMS

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: LeftChatPanel

function TOTEMS:Update(event)
	local displayedTotems = 0
	for i=1, MAX_TOTEMS do
		local haveTotem, name, startTime, duration, icon = GetTotemInfo(i);
		if haveTotem and icon and icon ~= '' then
			self.bar[i]:Show()
			self.bar[i].iconTexture:SetTexture(icon)
			displayedTotems = displayedTotems + 1
			CooldownFrame_SetTimer(self.bar[i].cooldown, startTime, duration, 1)

			for d=1, MAX_TOTEMS do
				if _G['TotemFrameTotem'..d..'IconTexture']:GetTexture() == icon then
					_G['TotemFrameTotem'..d]:ClearAllPoints();
					_G['TotemFrameTotem'..d]:SetParent(self.bar[i].holder);
					_G['TotemFrameTotem'..d]:SetAllPoints(self.bar[i].holder);
				end
			end
		else
			self.bar[i]:Hide()
		end
	end
end

function TOTEMS:ToggleEnable()
	if self.db.enable then
		self.bar:Show()
		self:RegisterEvent('PLAYER_TOTEM_UPDATE', 'Update')
		self:RegisterEvent('PLAYER_ENTERING_WORLD', 'Update')
		self:Update()
		E:EnableMover('TotemBarMover')
	else
		self.bar:Hide()
		self:UnregisterEvent('PLAYER_TOTEM_UPDATE')
		self:UnregisterEvent('PLAYER_ENTERING_WORLD')
		E:DisableMover('TotemBarMover')
	end
end

function TOTEMS:PositionAndSize()
	for i=1, MAX_TOTEMS do
		local button = self.bar[i]
		local prevButton = self.bar[i-1]
		button:Size(self.db.size)
		button:ClearAllPoints()
		if self.db.growthDirection == 'HORIZONTAL' and self.db.sortDirection == 'ASCENDING' then
			if i == 1 then
				button:Point('LEFT', self.bar, 'LEFT', self.db.spacing, 0)
			elseif prevButton then
				button:Point('LEFT', prevButton, 'RIGHT', self.db.spacing, 0)
			end
		elseif self.db.growthDirection == 'VERTICAL' and self.db.sortDirection == 'ASCENDING' then
			if i == 1 then
				button:Point('TOP', self.bar, 'TOP', 0, -self.db.spacing)
			elseif prevButton then
				button:Point('TOP', prevButton, 'BOTTOM', 0, -self.db.spacing)
			end
		elseif self.db.growthDirection == 'HORIZONTAL' and self.db.sortDirection == 'DESCENDING' then
			if i == 1 then
				button:Point('RIGHT', self.bar, 'RIGHT', -self.db.spacing, 0)
			elseif prevButton then
				button:Point('RIGHT', prevButton, 'LEFT', -self.db.spacing, 0)
			end
		else
			if i == 1 then
				button:Point('BOTTOM', self.bar, 'BOTTOM', 0, self.db.spacing)
			elseif prevButton then
				button:Point('BOTTOM', prevButton, 'TOP', 0, self.db.spacing)
			end
		end
	end

	if self.db.growthDirection == 'HORIZONTAL' then
		self.bar:Width(self.db.size*(MAX_TOTEMS) + self.db.spacing*(MAX_TOTEMS) + self.db.spacing)
		self.bar:Height(self.db.size + self.db.spacing*2)
	else
		self.bar:Height(self.db.size*(MAX_TOTEMS) + self.db.spacing*(MAX_TOTEMS) + self.db.spacing)
		self.bar:Width(self.db.size + self.db.spacing*2)
	end
	self:Update()
end


function TOTEMS:Initialize()
	self.db = E.db.general.totems

	local bar = CreateFrame('Frame', 'ElvUI_TotemBar', E.UIParent)
	bar = CreateFrame('Frame', 'ElvUI_TotemBar', E.UIParent)
	bar:Point('TOPLEFT', LeftChatPanel, 'TOPRIGHT', 14, 0)
	self.bar = bar;

	for i=1, MAX_TOTEMS do
		local frame = CreateFrame('Button', bar:GetName()..'Totem'..i, bar)
		frame:SetID(i)
		frame:SetTemplate('Default')
		frame:StyleButton()
		frame:Hide()
		frame.holder = CreateFrame('Frame', nil, frame)
		frame.holder:SetAlpha(0)
		frame.holder:SetAllPoints()

		frame.iconTexture = frame:CreateTexture(nil, 'ARTWORK')
		frame.iconTexture:SetInside()
		frame.iconTexture:SetTexCoord(unpack(E.TexCoords))

		frame.cooldown = CreateFrame('Cooldown', frame:GetName()..'Cooldown', frame, 'CooldownFrameTemplate')
		frame.cooldown:SetReverse(true)
		frame.cooldown:SetInside()
		E:RegisterCooldown(frame.cooldown)
		self.bar[i] = frame;
	end
	
	self:PositionAndSize()
	
	E:CreateMover(bar, 'TotemBarMover', L["Class Bar"]);
	self:ToggleEnable()
end

E:RegisterModule(TOTEMS:GetName())