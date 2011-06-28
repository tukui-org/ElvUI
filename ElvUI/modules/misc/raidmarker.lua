--Credit Baudzilla
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

local ButtonIsDown
local RaidMarkFrame = CreateFrame("Frame", nil, E.UIParent)
RaidMarkFrame:EnableMouse(true)
RaidMarkFrame:SetSize(100, 100)
RaidMarkFrame:SetFrameStrata("DIALOG")


local function RaidMarkCanMark()
	if GetNumRaidMembers() > 0 then
		if IsRaidLeader()or IsRaidOfficer()then
			return true
		else
			UIErrorsFrame:AddMessage("You don't have permission to mark targets.", 1.0, 0.1, 0.1, 1.0, UIERRORS_HOLD_TIME)
			return false
		end	
	else
		return true
	end
end


function RaidMark_HotkeyPressed(keystate)
	ButtonIsDown = (keystate=="down") and RaidMarkCanMark()
	if ButtonIsDown then
		RaidMarkShowIcons()
	else
		RaidMarkFrame:Hide()
	end
end


local function RaidMark_OnEvent()
	if ButtonIsDown then
		RaidMarkShowIcons()
	end
end


function RaidMarkShowIcons()
	if not UnitExists("target") or UnitIsDead("target")then
		return
	end
	local X, Y = GetCursorPosition()
	local Scale = E.UIParent:GetEffectiveScale()
	RaidMarkFrame:SetPoint("CENTER", E.UIParent, "BOTTOMLEFT", X / Scale, Y / Scale)
	RaidMarkFrame:Show()
end


local function RaidMarkButton_OnEnter(self)
	self.Texture:ClearAllPoints()
	self.Texture:SetPoint("TOPLEFT", -10, 10)
	self.Texture:SetPoint("BOTTOMRIGHT", 10, -10)
end


local function RaidMarkButton_OnLeave(self)
	self.Texture:SetAllPoints()
end


local function RaidMarkButton_OnClick(self, arg1)
	PlaySound("UChatScrollButton")
	SetRaidTarget("target", (arg1~="RightButton") and self:GetID()or 0)
	RaidMarkFrame:Hide()
end


RaidMarkFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
RaidMarkFrame:SetScript("OnEvent", RaidMark_OnEvent)


local Button, Angle
for i = 1, 8 do
	Button = CreateFrame("Button", "BaudMarkIconButton"..i, RaidMarkFrame)
	Button:SetSize(40, 40)
	Button:SetID(i)
	Button.Texture = Button:CreateTexture(Button:GetName().."NormalTexture", "ARTWORK");
	Button.Texture:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\raidicons.blp")
	Button.Texture:SetAllPoints()
	SetRaidTargetIconTexture(Button.Texture, i)
	Button:RegisterForClicks("LeftButtonUp","RightButtonUp")
	Button:SetScript("OnClick", RaidMarkButton_OnClick)
	Button:SetScript("OnEnter", RaidMarkButton_OnEnter)
	Button:SetScript("OnLeave", RaidMarkButton_OnLeave)
	if(i==8)then
		Button:SetPoint("CENTER")
	else
		Angle = 360 / 7 * i
		Button:SetPoint("CENTER", sin(Angle) * 60, cos(Angle) * 60)
	end
end

