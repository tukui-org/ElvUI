local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].greeting ~= true then return end

local function LoadSkin()
	QuestFrameGreetingPanel:HookScript("OnShow", function()
		QuestFrameGreetingPanel:StripTextures()
		E.SkinButton(QuestFrameGreetingGoodbyeButton, true)
		GreetingText:SetTextColor(1, 1, 1)
		CurrentQuestsText:SetTextColor(1, 1, 0)
		QuestGreetingFrameHorizontalBreak:Kill()
		AvailableQuestsText:SetTextColor(1, 1, 0)
		
		for i=1, MAX_NUM_QUESTS do
			local button = _G["QuestTitleButton"..i]
			if button:GetFontString() then
				if button:GetFontString():GetText() and button:GetFontString():GetText():find("|cff000000") then
					button:GetFontString():SetText(string.gsub(button:GetFontString():GetText(), "|cff000000", "|cffFFFF00"))
				end
			end
		end
	end)
end

tinsert(E.SkinFuncs["ElvUI"], LoadSkin)