local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars');

function AB:SetupExtraButton()
	local holder = CreateFrame('Frame', nil, E.UIParent)
	holder:Point('TOP', E.UIParent, 'TOP', 0, -250)
	holder:Size(ExtraActionBarFrame:GetSize())
	
	ExtraActionBarFrame:SetParent(holder)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint('CENTER', holder, 'CENTER')
		
	ExtraActionBarFrame.ignoreFramePositionManager  = true

	--[[ExtraActionBarFrame:Show(); ExtraActionBarFrame:SetAlpha(1); ExtraActionBarFrame.Hide = ExtraActionBarFrame.Show; ExtraActionBarFrame.SetAlpha = E.noop
	ExtraActionButton1.action = 2; ExtraActionButton1:Show(); ExtraActionButton1:SetAlpha(1); ExtraActionButton1.Hide = ExtraActionButton1.Show; ExtraActionButton1.SetAlpha = E.noop]]
	
	for i=1, ExtraActionBarFrame:GetNumChildren() do
		if _G["ExtraActionButton"..i] then
			_G["ExtraActionButton"..i].noResize = true;
			self:StyleButton(_G["ExtraActionButton"..i])
		end
	end
	
	E:CreateMover(holder, 'BossButton', 'Boss Button');
end