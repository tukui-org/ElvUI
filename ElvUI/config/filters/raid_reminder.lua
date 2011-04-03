--------------------------------------------------------------------------------------------
-- Raid Buff Reminder
--------------------------------------------------------------------------------------------

local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

E.BuffReminderRaidBuffs = {
	Flask = {
		94160, --"Flask of Flowing Water"
		79469, --"Flask of Steelskin"
		79470, --"Flask of the Draconic Mind"
		79471, --"Flask of the Winds
		79472, --"Flask of Titanic Strength"
		79638, --"Flask of Enhancement-STR"
		79639, --"Flask of Enhancement-AGI"
		79640, --"Flask of Enhancement-INT"
		92679, --Flask of battle
	},
	BattleElixir = {
		--Scrolls
		89343, --Agility
		63308, --Armor 
		89347, --Int
		89342, --Spirit
		63306, --Stam
		89346, --Strength
		
		--Elixirs
		79481, --Hit
		79632, --Haste
		79477, --Crit
		79635, --Mastery
		79474, --Expertise
		79468, --Spirit
	},
	GuardianElixir = {
		79480, --Armor
		79631, --Resistance+90
	},
	Food = {
		87545, --90 STR
		87546, --90 AGI
		87547, --90 INT
		87548, --90 SPI
		87549, --90 MAST
		87550, --90 HIT
		87551, --90 CRIT
		87552, --90 HASTE
		87554, --90 DODGE
		87555, --90 PARRY
		87635, --90 EXP
		87556, --60 STR
		87557, --60 AGI
		87558, --60 INT
		87559, --60 SPI
		87560, --60 MAST
		87561, --60 HIT
		87562, --60 CRIT
		87563, --60 HASTE
		87564, --60 DODGE
		87634, --60 EXP
		87554, --Seafood Feast
	},
}