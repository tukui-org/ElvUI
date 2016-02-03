local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions

--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_Stagger(frame)
	local stagger = CreateFrame("Statusbar", nil, frame)
	UF['statusbars'][stagger] = true
	stagger:CreateBackdrop("Default")
	stagger:SetOrientation("VERTICAL")
	stagger.PostUpdate = UF.PostUpdateStagger
	return stagger
end

function UF:SizeAndPosition_Stagger(frame)
	local stagger = frame.Stagger
	local db = frame.db

	frame.STAGGER_WIDTH = stagger and frame.STAGGER_SHOWN and (db.stagger.width + (frame.BORDER*2)) or 0;

	--TODO: Account for MIDDLE/RIGHT orientation
	if stagger and frame.STAGGER_SHOWN then
		if not frame.USE_MINI_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED and not frame.USE_POWERBAR_OFFSET then
			if frame.ORIENTATION == "LEFT" then
				stagger:Point('BOTTOMLEFT', frame.Power, 'BOTTOMRIGHT', frame.BORDER*2 + (-frame.BORDER + frame.SPACING*3), 0)
			elseif frame.ORIENTATION == "MIDDLE" then
			
			else
			
			end
		else
			if frame.ORIENTATION == "LEFT" then
				stagger:Point('BOTTOMLEFT', frame.Health, 'BOTTOMRIGHT', frame.BORDER*2 + (-frame.BORDER + frame.SPACING*3), 0)
			elseif frame.ORIENTATION == "MIDDLE" then
			
			else
			
			end
		end

		if frame.ORIENTATION == "LEFT" or frame.ORIENTATION == "MIDDLE" then
			stagger:Point('TOPRIGHT', frame.Health, 'TOPRIGHT', frame.STAGGER_WIDTH, 0)
		else
			
		end
	end
	
	if db.stagger.enable and not frame:IsElementEnabled('Stagger') then
		frame:EnableElement('Stagger')
	elseif not db.stagger.enable and frame:IsElementEnabled('Stagger') then
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
	
	--Only update when necessary
	if stateChanged then
		UF:SizeAndPosition_Stagger(frame)
		UF:SizeAndPosition_HealthBar(frame)
		UF:SizeAndPosition_Power(frame)
		--TODO: There should be a call to update classbar as well if it is not detached. Add this when classbars are ready.
	end
end