local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].lfr ~= true then return end

local function LoadSkin()
	local buttons = {
	  "LFRQueueFrameFindGroupButton",
	  "LFRQueueFrameAcceptCommentButton",
	  "LFRBrowseFrameSendMessageButton",
	  "LFRBrowseFrameInviteButton",
	  "LFRBrowseFrameRefreshButton",
	}

	LFRParentFrame:StripTextures()
	LFRParentFrame:SetTemplate("Transparent")
	LFRQueueFrame:StripTextures()
	LFRBrowseFrame:StripTextures()


	for i=1, #buttons do
	  E.SkinButton(_G[buttons[i]])
	end

	--Close button doesn't have a fucking name, extreme hackage
	for i=1, LFRParentFrame:GetNumChildren() do
	  local child = select(i, LFRParentFrame:GetChildren())
	  if child.GetPushedTexture and child:GetPushedTexture() and not child:GetName() then
		E.SkinCloseButton(child)
	  end
	end

	E.SkinTab(LFRParentFrameTab1)
	E.SkinTab(LFRParentFrameTab2)

	E.SkinDropDownBox(LFRBrowseFrameRaidDropDown)

	for i=1, 20 do
	  local button = _G["LFRQueueFrameSpecificListButton"..i.."ExpandOrCollapseButton"]

	  if button then
		button:HookScript("OnClick", function()
		  E.SkinCloseButton(button)
		end)
		E.SkinCloseButton(button)
	  end
	end

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
		E.SkinCheckBox(button.enableButton)
	end
	
	--DPS, Healer, Tank check button's don't have a name, use it's parent as a referance.
	E.SkinCheckBox(LFRQueueFrameRoleButtonTank:GetChildren())
	E.SkinCheckBox(LFRQueueFrameRoleButtonHealer:GetChildren())
	E.SkinCheckBox(LFRQueueFrameRoleButtonDPS:GetChildren())
	LFRQueueFrameRoleButtonTank:GetChildren():SetFrameLevel(LFRQueueFrameRoleButtonTank:GetChildren():GetFrameLevel() + 2)
	LFRQueueFrameRoleButtonHealer:GetChildren():SetFrameLevel(LFRQueueFrameRoleButtonHealer:GetChildren():GetFrameLevel() + 2)
	LFRQueueFrameRoleButtonDPS:GetChildren():SetFrameLevel(LFRQueueFrameRoleButtonDPS:GetChildren():GetFrameLevel() + 2)
	
	LFRQueueFrameSpecificListScrollFrame:StripTextures()
end

tinsert(E.SkinFuncs["ElvUI"], LoadSkin)