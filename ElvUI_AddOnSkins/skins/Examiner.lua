local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "ExaminerSkin"
local function SkinExaminer(self)

	-- Skin Examiner Frame
	AS:SkinFrame(Examiner)
	S:HandleScrollBar(ExaminerStatsScrollScrollBar)
	S:HandleScrollBar(ExaminerFeatsScrollScrollBar)
	S:HandleScrollBar(ExaminerGearScrollScrollBar)

	-- Skin Examiner Buttons
	for i = 1, Examiner:GetNumChildren() do
		local object = select(i, Examiner:GetChildren())
		if object:GetObjectType() == 'Button' then
			
			S:HandleButton(object, true)
		end
	end
end

AS:RegisterSkin(name,SkinExaminer)