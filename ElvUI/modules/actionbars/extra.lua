local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars');

function AB:SetupExtraButton()
	local holder = CreateFrame('Frame', nil, E.UIParent)
	holder:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 150)
	holder:Size(ExtraActionBarFrame:GetSize())
	
	ExtraActionBarFrame:SetParent(holder)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint('CENTER', holder, 'CENTER')
		
	ExtraActionBarFrame.ignoreFramePositionManager  = true
	
	for i=1, ExtraActionBarFrame:GetNumChildren() do
		if _G["ExtraActionButton"..i] then
			_G["ExtraActionButton"..i].noResize = true;
			_G["ExtraActionButton"..i].pushed = true
			_G["ExtraActionButton"..i].checked = true
			
			self:StyleButton(_G["ExtraActionButton"..i], true)
			_G["ExtraActionButton"..i]:SetTemplate()
			_G["ExtraActionButton"..i..'Icon']:SetDrawLayer('ARTWORK')
			local tex = _G["ExtraActionButton"..i]:CreateTexture(nil, 'OVERLAY')
			tex:SetTexture(0.9, 0.8, 0.1, 0.3)
			tex:SetInside()
			_G["ExtraActionButton"..i]:SetCheckedTexture(tex)
		end
	end
	
	if HasExtraActionBar() then
		ExtraActionBarFrame:Show();
	end
	
	E:CreateMover(holder, 'BossButton', L['Boss Button'], nil, nil, nil, 'ALL,ACTIONBARS');
end