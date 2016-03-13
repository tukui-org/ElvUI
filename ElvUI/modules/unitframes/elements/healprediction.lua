local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_HealComm(frame)
	local mhpb = CreateFrame('StatusBar', nil, frame)
	mhpb:SetStatusBarTexture(E["media"].blankTex)
	mhpb:SetFrameLevel(frame.Health:GetFrameLevel() - 2)
	mhpb:Hide()

	local ohpb = CreateFrame('StatusBar', nil, frame)
	ohpb:SetStatusBarTexture(E["media"].blankTex)
	mhpb:SetFrameLevel(mhpb:GetFrameLevel())
	ohpb:Hide()

	local absorbBar = CreateFrame('StatusBar', nil, frame)
	absorbBar:SetStatusBarTexture(E["media"].blankTex)
	absorbBar:SetFrameLevel(mhpb:GetFrameLevel())
	absorbBar:Hide()

	if frame.Health then
		ohpb:SetParent(frame.Health)
		mhpb:SetParent(frame.Health)
		absorbBar:SetParent(frame.Health)
	end

	return {
		myBar = mhpb,
		otherBar = ohpb,
		absorbBar = absorbBar,
		maxOverflow = 1,
		PostUpdate = UF.UpdateHealComm
	}
end

local function UpdateFillBar(frame, previousTexture, bar, amount)
	if ( amount == 0 ) then
		bar:Hide();
		return previousTexture;
	end

	local orientation = frame.Health:GetOrientation()
	bar:ClearAllPoints()
	if orientation == 'HORIZONTAL' then
		bar:SetPoint("TOPLEFT", previousTexture, "TOPRIGHT");
		bar:SetPoint("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT");
	else
		bar:SetPoint("BOTTOMRIGHT", previousTexture, "TOPRIGHT");
		bar:SetPoint("BOTTOMLEFT", previousTexture, "TOPLEFT");
	end

	local totalWidth, totalHeight = frame.Health:GetSize();
	if orientation == 'HORIZONTAL' then
		bar:SetWidth(totalWidth);
	else
		bar:SetHeight(totalHeight);
	end

	return bar:GetStatusBarTexture();
end

function UF:UpdateHealComm(unit, myIncomingHeal, allIncomingHeal, totalAbsorb)
	local frame = self.parent
	local previousTexture = frame.Health:GetStatusBarTexture();

	previousTexture = UpdateFillBar(frame, previousTexture, self.myBar, myIncomingHeal);
	previousTexture = UpdateFillBar(frame, previousTexture, self.otherBar, allIncomingHeal);
	previousTexture = UpdateFillBar(frame, previousTexture, self.absorbBar, totalAbsorb);
end