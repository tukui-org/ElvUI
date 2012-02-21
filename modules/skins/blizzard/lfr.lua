local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.global.skins.blizzard.enable ~= true or E.global.skins.blizzard.lfr ~= true then return end
	
	local buttons = {
	  "LFRQueueFrameFindGroupButton",
	  "LFRQueueFrameAcceptCommentButton",
	  "LFRBrowseFrameSendMessageButton",
	  "LFRBrowseFrameInviteButton",
	  "LFRBrowseFrameRefreshButton",
	}

	LFRParentFrame:StripTextures()
	
	if not E:IsPTRVersion() then
		LFRParentFrame:SetTemplate("Transparent")
	end
	
	LFRQueueFrame:StripTextures()
	LFRBrowseFrame:StripTextures()


	for i=1, #buttons do
	  S:HandleButton(_G[buttons[i]])
	end

	--Close button doesn't have a fucking name, extreme hackage
	for i=1, LFRParentFrame:GetNumChildren() do
	  local child = select(i, LFRParentFrame:GetChildren())
	  if child.GetPushedTexture and child:GetPushedTexture() and not child:GetName() then
		S:HandleCloseButton(child)
	  end
	end

	S:HandleTab(LFRParentFrameTab1)
	S:HandleTab(LFRParentFrameTab2)

	S:HandleDropDownBox(LFRBrowseFrameRaidDropDown)

	LFRQueueFrameCommentTextButton:CreateBackdrop("Default")
	LFRQueueFrameCommentTextButton:Height(35)

	for i=1, 7 do
		local button = "LFRBrowseFrameColumnHeader"..i
		_G[button.."Left"]:Kill()
		_G[button.."Middle"]:Kill()
		_G[button.."Right"]:Kill()
	end		
	
	for i=1, NUM_LFR_CHOICE_BUTTONS do
		local button = _G["LFRQueueFrameSpecificListButton"..i]
		S:HandleCheckBox(button.enableButton)
	end
	
	--DPS, Healer, Tank check button's don't have a name, use it's parent as a referance.
	S:HandleCheckBox(LFRQueueFrameRoleButtonTank:GetChildren())
	S:HandleCheckBox(LFRQueueFrameRoleButtonHealer:GetChildren())
	S:HandleCheckBox(LFRQueueFrameRoleButtonDPS:GetChildren())
	LFRQueueFrameRoleButtonTank:GetChildren():SetFrameLevel(LFRQueueFrameRoleButtonTank:GetChildren():GetFrameLevel() + 2)
	LFRQueueFrameRoleButtonHealer:GetChildren():SetFrameLevel(LFRQueueFrameRoleButtonHealer:GetChildren():GetFrameLevel() + 2)
	LFRQueueFrameRoleButtonDPS:GetChildren():SetFrameLevel(LFRQueueFrameRoleButtonDPS:GetChildren():GetFrameLevel() + 2)
	
	LFRQueueFrameSpecificListScrollFrame:StripTextures()
	
	--Skill Line Tabs
	for i=1, 2 do
		local tab = _G["LFRParentFrameSideTab"..i]
		if tab then
			local tex = tab:GetNormalTexture():GetTexture()
			tab:StripTextures()
			tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			tab:GetNormalTexture():ClearAllPoints()
			tab:GetNormalTexture():Point("TOPLEFT", 2, -2)
			tab:GetNormalTexture():Point("BOTTOMRIGHT", -2, 2)
			tab:SetNormalTexture(tex)
			
			tab:CreateBackdrop("Default")
			tab.backdrop:SetAllPoints()
			tab:StyleButton(true)				
			
			local point, relatedTo, point2, x, y = tab:GetPoint()
			tab:Point(point, relatedTo, point2, 1, y)
		end
	end
	
	--PTR
	if E:IsPTRVersion() then
		RaidParentFrame:StripTextures()
		RaidParentFrame:SetTemplate('Transparent')
		
		for i=1, 3 do 
			S:HandleTab(_G['RaidParentFrameTab'..i])
		end
		
		S:HandleButton(RaidFinderFrameFindRaidButton, true)
		S:HandleButton(RaidFinderFrameCancelButton, true)
		S:HandleDropDownBox(RaidFinderQueueFrameSelectionDropDown)
		RaidFinderQueueFrame:StripTextures()
		RaidParentFrameInset:StripTextures()
		RaidFinderQueueFrame:StripTextures(true)
		RaidFinderFrameRoleInset:StripTextures()
		
		RaidFinderQueueFrameSelectionDropDown:Width(225)
		RaidFinderQueueFrameSelectionDropDown.SetWidth = E.noop

		local checkButtons = {
			"RaidFinderQueueFrameRoleButtonTank",
			"RaidFinderQueueFrameRoleButtonHealer",
			"RaidFinderQueueFrameRoleButtonDPS",
			"RaidFinderQueueFrameRoleButtonLeader",
		}
		
		for _, object in pairs(checkButtons) do
			_G[object].checkButton:SetFrameLevel(_G[object].checkButton:GetFrameLevel() + 2)
			S:HandleCheckBox(_G[object].checkButton)
		end
	
		for i=1, 1 do
			local button = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i]
			local icon = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i.."IconTexture"]
			local count = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i.."Count"]
			
			if button then
				local __texture = _G[button:GetName().."IconTexture"]:GetTexture()
				button:StripTextures()
				icon:SetTexture(__texture)
				icon:SetTexCoord(unpack(E.TexCoords))
				icon:Point("TOPLEFT", 2, -2)
				icon:SetDrawLayer("OVERLAY")
				count:SetDrawLayer("OVERLAY")
				if not button.backdrop then
					button:CreateBackdrop("Default")
					button.backdrop:Point("TOPLEFT", icon, "TOPLEFT", -2, 2)
					button.backdrop:Point("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
					icon:SetParent(button.backdrop)
					icon.SetPoint = E.noop
					
					if count then
						count:SetParent(button.backdrop)
					end					
				end
			end
		end			
		
		S:HandleCloseButton(RaidParentFrameCloseButton)
	end
end

S:RegisterSkin('ElvUI', LoadSkin)