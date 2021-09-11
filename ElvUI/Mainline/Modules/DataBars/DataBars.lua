local E, L, V, P, G = unpack(select(2, ...))
local DB = E:GetModule('DataBars')

function DB:Initialize()
	DB.Initialized = true
	DB.StatusBars = {}

	DB.db = E.db.databars

	DB:ExperienceBar()
	DB:ReputationBar()
	DB:HonorBar()
	DB:AzeriteBar()
	DB:ThreatBar()

	DB:UpdateAll()

	DB:RegisterEvent('PLAYER_LEVEL_UP', 'HandleVisibility')
	DB:RegisterEvent('PLAYER_ENTERING_WORLD', 'HandleVisibility')
	DB:RegisterEvent('PLAYER_REGEN_DISABLED', 'HandleVisibility')
	DB:RegisterEvent('PLAYER_REGEN_ENABLED', 'HandleVisibility')
	DB:RegisterEvent('PVP_TIMER_UPDATE', 'HandleVisibility')
end
