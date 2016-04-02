local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions

--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_Stagger(frame)
	local stagger = CreateFrame("Statusbar", nil, frame)
	UF['statusbars'][stagger] = true
	stagger:CreateBackdrop("Default",nil, nil, self.thinBorders)
	stagger:SetOrientation("VERTICAL")
	stagger.PostUpdate = UF.PostUpdateStagger
	stagger:SetFrameStrata("LOW")
	return stagger
end

function UF:Configure_Stagger(frame)
	local stagger = frame.Stagger
	local db = frame.db

	frame.STAGGER_WIDTH = stagger and frame.STAGGER_SHOWN and (db.stagger.width + (frame.BORDER*2)) or 0;

	if db.stagger.enable then
		if not frame:IsElementEnabled('Stagger') then
			frame:EnableElement('Stagger')
		end

		stagger:ClearAllPoints()
		if not frame.USE_MINI_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED and not frame.USE_POWERBAR_OFFSET then
			if frame.ORIENTATION == "RIGHT" then
				--Position on left side of health because portrait is on right side
				stagger:Point('BOTTOMRIGHT', frame.Power, 'BOTTOMLEFT', -frame.BORDER*2 + (frame.BORDER - frame.SPACING*3), 0)
				stagger:Point('TOPLEFT', frame.Health, 'TOPLEFT', -frame.STAGGER_WIDTH, 0)
			else
				--Position on right side
				stagger:Point('BOTTOMLEFT', frame.Power, 'BOTTOMRIGHT', frame.BORDER*2 + (-frame.BORDER + frame.SPACING*3), 0)
				stagger:Point('TOPRIGHT', frame.Health, 'TOPRIGHT', frame.STAGGER_WIDTH, 0)
			end
		else
			if frame.ORIENTATION == "RIGHT" then
				--Position on left side of health because portrait is on right side
				stagger:Point('BOTTOMRIGHT', frame.Health, 'BOTTOMLEFT', -frame.BORDER*2 + (frame.BORDER - frame.SPACING*3), 0)
				stagger:Point('TOPLEFT', frame.Health, 'TOPLEFT', -frame.STAGGER_WIDTH, 0)
			else
				--Position on right side
				stagger:Point('BOTTOMLEFT', frame.Health, 'BOTTOMRIGHT', frame.BORDER*2 + (-frame.BORDER + frame.SPACING*3), 0)
				stagger:Point('TOPRIGHT', frame.Health, 'TOPRIGHT', frame.STAGGER_WIDTH, 0)
			end
		end
	elseif frame:IsElementEnabled('Stagger') then
		frame:DisableElement('Stagger')
	end
end

function UF:PostUpdateStagger()
	local frame = self:GetParent()
	local db = frame.db

	local stateChanged = false
	local isShown = self:IsShown()

	--Check if Stagger has changed to be either shown or hidden
	if (frame.STAGGER_SHOWN and not isShown) or (not frame.STAGGER_SHOWN and isShown) then
		stateChanged = true
	end

	frame.STAGGER_SHOWN = isShown

	--[[
		--Use this to force it to show for testing purposes
		self.Hide = self.Show
		self:SetMinMaxValues(0, 100)
		self:SetValue(50)
		self.SetValue = function() end
		self:Show()
		frame.STAGGER_SHOWN = true
	--]]

	--Only update when necessary
	if stateChanged then
		UF:Configure_Stagger(frame)
		UF:Configure_HealthBar(frame)
		UF:Configure_Power(frame)
		UF:Configure_InfoPanel(frame, true) --2nd argument is to prevent it from setting template, which removes threat border
	end
end