-- Credit Baudzilla and Simpy
local E, L, V, P, G = unpack(ElvUI)
local M = E:GetModule('Misc')

local format = format
local sin, cos, rad = math.sin, math.cos, rad -- sin~=math.sin, cos~=math.cos, rad==math.rad; why? who knows? :P

local CreateFrame = CreateFrame
local GetCursorPosition = GetCursorPosition
local GetNumGroupMembers = GetNumGroupMembers
local IsInGroup, IsInRaid = IsInGroup, IsInRaid
local UnitExists, UnitIsDead = UnitExists, UnitIsDead
local SetRaidTargetIconTexture = SetRaidTargetIconTexture
local UnitIsGroupAssistant = UnitIsGroupAssistant
local UnitIsGroupLeader = UnitIsGroupLeader
local PlaySound = PlaySound

local TM = _G.SLASH_TARGET_MARKER4

-- GLOBALS: RaidMark_HotkeyPressed

function M:RaidMarkCanMark()
	if not self.RaidMarkFrame then
		return false
	elseif GetNumGroupMembers() > 0 then
		if UnitIsGroupLeader('player') or UnitIsGroupAssistant('player') then
			return true
		elseif IsInGroup() and not IsInRaid() then
			return true
		else
			_G.UIErrorsFrame:AddMessage(L["You don't have permission to mark targets."], 1.0, 0.1, 0.1, 1.0)

			return false
		end
	end

	return true
end

function M:RaidMarkShowIcons()
	if not UnitExists('target') or UnitIsDead('target') then return end

	local x, y = GetCursorPosition()
	local scale = E.UIParent:GetEffectiveScale()
	self.RaidMarkFrame:Point('CENTER', E.UIParent, 'BOTTOMLEFT', x / scale, y / scale)
	self.RaidMarkFrame:Show()
end

function M:RaidMarkButton_OnEnter()
	self.Texture:ClearAllPoints()
	self.Texture:Point('TOPLEFT', -10, 10)
	self.Texture:Point('BOTTOMRIGHT', 10, -10)
end

function M:RaidMarkButton_OnLeave()
	self.Texture:SetAllPoints()
end

function M:RaidMarkButton_MouseUp()
	PlaySound(1115) -- U_CHAT_SCROLL_BUTTON

	self:GetParent():Hide()
end

do
	local ANG_RAD = rad(360) / 7
	function M:LoadRaidMarker()
		local marker = CreateFrame('Frame', nil, E.UIParent)
		marker:EnableMouse(true)
		marker:SetFrameStrata('DIALOG')
		marker:Size(100)

		for i = 1, 8 do
			local tm = format('%s %d', TM, i)
			local name = 'RaidMarkIconButton'..i
			local button = CreateFrame('Button', name, marker, 'SecureActionButtonTemplate')
			button:SetScript('OnMouseUp', M.RaidMarkButton_MouseUp)
			button:SetScript('OnEnter', M.RaidMarkButton_OnEnter)
			button:SetScript('OnLeave', M.RaidMarkButton_OnLeave)
			button:SetAttribute('type1', 'macro')
			button:SetAttribute('type2', 'macro')
			button:SetAttribute('macrotext1', tm)
			button:SetAttribute('macrotext2', tm)
			button:Size(40)
			button:SetID(i)

			E:RegisterClicks(button)

			button.Texture = button:CreateTexture(name..'NormalTexture', 'ARTWORK')
			button.Texture:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
			button.Texture:SetAllPoints()

			SetRaidTargetIconTexture(button.Texture, i)

			if i == 8 then
				button:Point('CENTER')
			else
				local angle = ANG_RAD * (i - 1)
				button:Point('CENTER', sin(angle) * 60, cos(angle) * 60)
			end
		end

		M.RaidMarkFrame = marker
	end
end

do
	local ButtonIsDown
	function M:RaidMark_OnEvent()
		if ButtonIsDown and self.RaidMarkFrame then
			self:RaidMarkShowIcons()
		end
	end

	function RaidMark_HotkeyPressed(keystate)
		ButtonIsDown = (keystate == 'down') and M:RaidMarkCanMark()

		if ButtonIsDown and M.RaidMarkFrame then
			M:RaidMarkShowIcons()
		elseif M.RaidMarkFrame then
			M.RaidMarkFrame:Hide()
		end
	end
end

M:RegisterEvent('PLAYER_TARGET_CHANGED', 'RaidMark_OnEvent')
