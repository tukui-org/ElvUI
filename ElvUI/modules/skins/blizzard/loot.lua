local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')
local LBG = LibStub("LibButtonGlow-1.0", true)

local function LoadSkin()
	LootHistoryFrame:SetFrameStrata('HIGH')
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.loot ~= true then return end
	local frame = MissingLootFrame

	frame:StripTextures()
	frame:CreateBackdrop("Default")

	S:HandleCloseButton(MissingLootFramePassButton)

	local function SkinButton()
		local numItems = GetNumMissingLootItems()

		for i = 1, numItems do
			local slot = _G["MissingLootFrameItem"..i]
			local icon = slot.icon

			S:HandleItemButton(slot, true)

			local texture, name, count, quality = GetMissingLootItemInfo(i);
			local color = (GetItemQualityColor(quality)) or (unpack(E.media.bordercolor))
			icon:SetTexture(texture)
			frame:SetBackdropBorderColor(color)
		end

		local numRows = ceil(numItems / 2);
		MissingLootFrame:SetHeight(numRows * 43 + 38 + MissingLootFrameLabel:GetHeight());
	end
	hooksecurefunc("MissingLootFrame_Show", SkinButton)

	-- loot history frame
	LootHistoryFrame:StripTextures()
	S:HandleCloseButton(LootHistoryFrame.CloseButton)
	LootHistoryFrame:StripTextures()
	LootHistoryFrame:SetTemplate('Transparent')
	S:HandleCloseButton(LootHistoryFrame.ResizeButton)
	LootHistoryFrame.ResizeButton.text:SetText("v v v v")
	LootHistoryFrame.ResizeButton:SetTemplate()
	LootHistoryFrame.ResizeButton:Width(LootHistoryFrame:GetWidth())
	LootHistoryFrame.ResizeButton:Height(19)
	LootHistoryFrame.ResizeButton:ClearAllPoints()
	LootHistoryFrame.ResizeButton:Point("TOP", LootHistoryFrame, "BOTTOM", 0, -2)
	LootHistoryFrameScrollFrame:StripTextures()
	S:HandleScrollBar(LootHistoryFrameScrollFrameScrollBar)

	local function UpdateLoots(self)
		local numItems = C_LootHistory.GetNumItems()
		for i=1, numItems do
			local frame = LootHistoryFrame.itemFrames[i]

			if not frame.isSkinned then
				local Icon = frame.Icon:GetTexture()
				frame:StripTextures()
				frame.Icon:SetTexture(Icon)
				frame.Icon:SetTexCoord(unpack(E.TexCoords))

				-- create a backdrop around the icon
				frame:CreateBackdrop("Default")
				frame.backdrop:SetOutside(frame.Icon)
				frame.Icon:SetParent(frame.backdrop)

				frame.isSkinned = true
			end
		end
	end
	hooksecurefunc("LootHistoryFrame_FullUpdate", UpdateLoots)

	--masterloot
	MasterLooterFrame:StripTextures()
	MasterLooterFrame:SetTemplate()
	MasterLooterFrame:SetFrameStrata('FULLSCREEN_DIALOG')
	MasterLooterFrame:SetFrameLevel(10)

	hooksecurefunc("MasterLooterFrame_Show", function()
		local b = MasterLooterFrame.Item
		if b then
			local i = b.Icon
			local icon = i:GetTexture()
			local c = ITEM_QUALITY_COLORS[LootFrame.selectedQuality]

			b:StripTextures()
			i:SetTexture(icon)
			i:SetTexCoord(unpack(E.TexCoords))
			b:CreateBackdrop()
			b.backdrop:SetOutside(i)
			b.backdrop:SetBackdropBorderColor(c.r, c.g, c.b)
		end

		for i=1, MasterLooterFrame:GetNumChildren() do
			local child = select(i, MasterLooterFrame:GetChildren())
			if child and not child.isSkinned and not child:GetName() then
				if child:GetObjectType() == "Button" then
					if child:GetPushedTexture() then
						S:HandleCloseButton(child)
					else
						child:SetTemplate()
						child:StyleButton()
					end
					child.isSkinned = true
				end
			end
		end
	end)

	BonusRollFrame:StripTextures()
	BonusRollFrame:SetTemplate('Transparent')
	BonusRollFrame.PromptFrame.Icon:SetTexCoord(unpack(E.TexCoords))
	BonusRollFrame.PromptFrame.IconBackdrop = CreateFrame("Frame", nil, BonusRollFrame.PromptFrame)
	BonusRollFrame.PromptFrame.IconBackdrop:SetFrameLevel(BonusRollFrame.PromptFrame.IconBackdrop:GetFrameLevel() - 1)
	BonusRollFrame.PromptFrame.IconBackdrop:SetOutside(BonusRollFrame.PromptFrame.Icon)
	BonusRollFrame.PromptFrame.IconBackdrop:SetTemplate()
	BonusRollFrame.PromptFrame.Timer.Bar:SetTexture(1, 1, 1)
	BonusRollFrame.PromptFrame.Timer.Bar:SetVertexColor(1, 1, 1)

	LootFrame:StripTextures()
	LootFrameInset:StripTextures()
	LootFrame:SetHeight(LootFrame:GetHeight() - 30)
	S:HandleCloseButton(LootFrameCloseButton)

	LootFrame:SetTemplate("Transparent")
	LootFrame:SetFrameStrata("FULLSCREEN")
	LootFrame:SetFrameLevel(1)
	LootFramePortraitOverlay:SetParent(E.HiddenFrame)

	for i=1, LootFrame:GetNumRegions() do
		local region = select(i, LootFrame:GetRegions());
		if(region:GetObjectType() == "FontString") then
			if(region:GetText() == ITEMS) then
				LootFrame.Title = region
			end
		end
	end

	LootFrame.Title:ClearAllPoints()
	LootFrame.Title:SetPoint("TOPLEFT", LootFrame, "TOPLEFT", 4, -4)
	LootFrame.Title:SetJustifyH("LEFT")

	for i=1, LOOTFRAME_NUMBUTTONS do
		local button = _G["LootButton"..i]
		_G["LootButton"..i.."NameFrame"]:Hide()
		S:HandleItemButton(button, true)

		_G["LootButton"..i.."IconQuestTexture"]:SetParent(E.HiddenFrame)

		local point, attachTo, point2, x, y = button:GetPoint()
		button:ClearAllPoints()
		button:SetPoint(point, attachTo, point2, x, y+30)
	end

	hooksecurefunc("LootFrame_UpdateButton", function(index)
		local numLootItems = LootFrame.numLootItems;
		--Logic to determine how many items to show per page
		local numLootToShow = LOOTFRAME_NUMBUTTONS;
		local self = LootFrame;
		if( self.AutoLootTable ) then
			numLootItems = #self.AutoLootTable;
		end
		if ( numLootItems > LOOTFRAME_NUMBUTTONS ) then
			numLootToShow = numLootToShow - 1; -- make space for the page buttons
		end

		local button = _G["LootButton"..index];
		local slot = (numLootToShow * (LootFrame.page - 1)) + index;
		if(button and button:IsShown()) then
			local texture, item, quantity, quality, locked, isQuestItem, questId, isActive;
			if(LootFrame.AutoLootTablLootFramee)then
				local entry = LootFrame.AutoLootTable[slot];
				if( entry.hide ) then
					button:Hide();
					return;
				else
					texture = entry.texture;
					item = entry.item;
					quantity = entry.quantity;
					quality = entry.quality;
					locked = entry.locked;
					isQuestItem = entry.isQuestItem;
					questId = entry.questId;
					isActive = entry.isActive;
				end
			else
				texture, item, quantity, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(slot);
			end

			if(texture) then
				if ( questId and not isActive ) then
					LBG.ShowOverlayGlow(button)
				elseif ( questId or isQuestItem ) then
					LBG.ShowOverlayGlow(button)
				else
					LBG.HideOverlayGlow(button)
				end
			end
		end
	end)

	LootFrame:HookScript("OnShow", function(self)
		if(IsFishingLoot()) then
			self.Title:SetText(L["Fishy Loot"])
		elseif(not UnitIsFriend("player", "target") and UnitIsDead"target") then
			self.Title:SetText(UnitName("target"))
		else
			self.Title:SetText(LOOT)
		end
	end)

	S:HandleNextPrevButton(LootFrameDownButton)
	S:HandleNextPrevButton(LootFrameUpButton)
	SquareButton_SetIcon(LootFrameUpButton, 'UP')
	SquareButton_SetIcon(LootFrameDownButton, 'DOWN')
end

S:RegisterSkin("ElvUI", LoadSkin)