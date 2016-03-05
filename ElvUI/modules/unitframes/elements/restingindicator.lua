local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions

--WoW API / Variables

function UF:Construct_RestingIndicator(frame)
	local resting = frame:CreateTexture(nil, "OVERLAY")
	resting:Size(22)

	return resting
end

function UF:Configure_RestingIndicator(frame)
	local rIcon = frame.Resting
	local db = frame.db
	if db.restIcon then
		if not frame:IsElementEnabled('Resting') then
			frame:EnableElement('Resting')
		end

		rIcon:ClearAllPoints()
		if frame.ORIENTATION == "RIGHT" then
			rIcon:Point("CENTER", frame.Health, "TOPLEFT", -3, 6)
		else
			if frame.USE_PORTRAIT and not frame.USE_PORTRAIT_OVERLAY then
				rIcon:Point("CENTER", frame.Portrait, "TOPLEFT", -3, 6)
			else
				rIcon:Point("CENTER", frame.Health, "TOPLEFT", -3, 6)
			end
		end
	elseif frame:IsElementEnabled('Resting') then
		frame:DisableElement('Resting')
		rIcon:Hide()
	end
end