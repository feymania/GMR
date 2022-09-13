--- VERSION v1.8.0

local CFG = {
	runeTapHpUse = 80,
	vampiricBloodHpUse = 70,
	iceboundFortitudeHpUse = 50,
	bloodBoilEnabled = true,
	useBloodFillersWithBloodRunesOnly = true,
	bloodBoilMinEnemies = 3,
	--- Default presence
	defaultPresence = 1, -- 1:blood, 2:frost, 3:unholy
	--- Change presence on frost, if HP < X. Change it to 0 to turn off
	minHpToChangeToFrostPresence = 60, -- change it to 0 to turn off
	minEnemiesCountToRaiseDead = 2,
	debug = false,
	useCombatRotationLauncher = true,
}

local shouldLaunch = false
-- turn on only for death knight class
if GMR.GetClass("player") == "DEATHKNIGHT" then
	shouldLaunch = true
end

local spells = {
	plagueStrike = GetSpellInfo(45462),
	bloodPlague = GetSpellInfo(55078), -- plagues strike's debuff
	icyTouch = GetSpellInfo(45477),
	frostFever = GetSpellInfo(55095), -- icy touch's debuff
	pestilence = GetSpellInfo(50842),
	heartStrike = GetSpellInfo(55050),
	bloodStrike = GetSpellInfo(45902),
	deathStrike = GetSpellInfo(49998),
	runeTap = GetSpellInfo(48982),
	vampiricBlood = GetSpellInfo(55233),
	iceboundFortitude = GetSpellInfo(48792),
	bloodBoil = GetSpellInfo(48721),
	bloodTap = GetSpellInfo(45529),
	deathCoil = GetSpellInfo(47541),
	bloodPresence = GetSpellInfo(48266),
	frostPresence = GetSpellInfo(48263),
	unholyPresence = GetSpellInfo(48265),
	runeStrike = GetSpellInfo(56815),
	raiseDead = GetSpellInfo(46584),
	deathPact = GetSpellInfo(48743),
	hornOfWinter = GetSpellInfo(57330),
}

local spellKnown = {
	pestilence = GMR.IsSpellKnown(spells.pestilence),
	heartStrike = GMR.IsSpellKnown(spells.heartStrike),
	deathStrike = GMR.IsSpellKnown(spells.deathStrike),
	runeTap = GMR.IsSpellKnown(spells.runeTap),
	vampiricBlood = GMR.IsSpellKnown(spells.vampiricBlood),
	iceboundFortitude = GMR.IsSpellKnown(spells.iceboundFortitude),
	bloodBoil = GMR.IsSpellKnown(spells.bloodBoil),
	bloodTap = GMR.IsSpellKnown(spells.bloodTap),
	frostPresence = GMR.IsSpellKnown(spells.frostPresence),
	unholyPresence = GMR.IsSpellKnown(spells.unholyPresence),
	runeStrike = GMR.IsSpellKnown(spells.runeStrike),
	raiseDead = GMR.IsSpellKnown(spells.raiseDead),
	hornOfWinter = GMR.IsSpellKnown(spells.hornOfWinter),
}

local glyphSpells = {
	glyphOfDisease = GetSpellInfo(63334),
	glyphOfPestilence = GetSpellInfo(59309),
	glyphOfRaiseDead = GetSpellInfo(60200),
}

local state = {
	defaultPresenceSkill = spells.bloodPresence,
	hasGlyphOfDisease = false,
	pestilenceRadius = 10,
	raiseDeadConsumeItem = true,
}

local RUNETYPE_BLOOD = 1
local RUNETYPE_UNHOLY = 2
local RUNETYPE_FROST = 3
local RUNETYPE_DEATH = 4

local function determineState()
	if not shouldLaunch then
		return
	end

	if CFG.defaultPresence == 1 then
		state.defaultPresenceSkill = spells.bloodPresence
	elseif CFG.defaultPresence == 2 and spellKnown.frostPresence then
		state.defaultPresenceSkill = spells.frostPresence
	elseif CFG.defaultPresence == 3 and spellKnown.unholyPresence then
		state.defaultPresenceSkill = spells.unholyPresence
	end

	for socketId = 1, GetNumGlyphSockets() do
		local enabled, _, spellId = GetGlyphSocketInfo(socketId)
		if enabled then
			local spellInfo = GetSpellInfo(spellId)
			if spellInfo == glyphSpells.glyphOfDisease then
				GMR.Print("Character has Glyph of Disease, CR should use pestilence to renew debuffs.")
				state.hasGlyphOfDisease = true
			elseif spellInfo == glyphSpells.glyphOfPestilence then
				GMR.Print("Character has Glyph of Pestilence, radius of Pestilence is 15 now.")
				state.pestilenceRadius = 15
			elseif spellInfo == glyphSpells.glyphOfRaiseDead then
				state.raiseDeadConsumeItem = false
			end
		end
	end

end
determineState()

local function dbgPrint(msg)
	if not CFG.debug then
		return
	end

	local message = "[DEBUG] " .. msg
	GMR.Print(message)
	GMR.Log(message)
end

---@return boolean spell casted
local function useSpellWithPreBloodTap(spell, unit)
	-- spell cd and shortage on runes use same cooldown info, so we can understand which type of CD it only by CD
	-- duration
	local cooldownDuration = select(2, GetSpellCooldown(spell))
	if cooldownDuration > 10 then
		return false
	end

	if not GMR.IsCastable(spell, unit) and spellKnown.bloodTap then
		if GetSpellCooldown(spells.bloodTap) == 0 then
			dbgPrint("should cast blood tap to generate blood rune")
			GMR.Cast(spells.bloodTap, "player")
			return true
		end
	end

	if GMR.IsCastable(spell, unit) then
		dbgPrint("should cast blood tap to generate blood rune")
		GMR.Cast(spell, unit)
		return true
	end

	return false
end

---Calculate available runes and group them by type
---@return table<number, number> map runeType to count
local function calculateRunes()
	local runesSummary = {
		[RUNETYPE_BLOOD] = 0,
		[RUNETYPE_FROST] = 0,
		[RUNETYPE_UNHOLY] = 0,
		[RUNETYPE_DEATH] = 0,
	}
	for runeSlot = 1, 6 do
		if select(3, GetRuneCooldown(runeSlot)) then
			local runeType = GetRuneType(runeSlot)
			runesSummary[runeType] = runesSummary[runeType] + 1
		end
	end

	return runesSummary
end

local function combatRotation()
	if spellKnown.raiseDead and GetSpellCooldown(spells.raiseDead) > 0 then
		local cooldown = GetSpellCooldown(spells.raiseDead) - GetTime()
		if cooldown >= 55 and cooldown <= 60 and GMR.GetHealth("player") < 100
			and GMR.IsCastable(spells.deathPact)
		then
			dbgPrint("should cast Death Pact to heal")
			GMR.Cast(spells.deathPact, "player")
			return
		end
	end

	if spellKnown.runeStrike and GMR.IsCastable(spells.runeStrike, "target") then
		dbgPrint("should turn on rune strike")
		GMR.Cast(spells.runeStrike)
	end

	--dbgPrint("should do")

	if UnitPower("player", 6) >= 85 and GMR.IsCastable(spells.deathCoil, "target") and GMR.IsSpellInRange(spells.deathCoil, "target") then
		dbgPrint("use deth coil to spend rune power")
		GMR.Cast(spells.deathCoil, "target")
		return
	end

	if GMR.HasBuff("player", state.defaultPresenceSkill) then
		if state.defaultPresenceSkill ~= spells.frostPresence and GMR.GetHealth("player") < CFG.minHpToChangeToFrostPresence
			and GMR.IsCastable(spells.frostPresence, "player")
		then
			dbgPrint("should use frost presence")
			GMR.Cast(spells.frostPresence, "player")
			return
		end
	else
		if GMR.GetHealth("player") >= 99 and GMR.IsCastable(state.defaultPresenceSkill, "player") then
			dbgPrint("should use default presence '"..state.defaultPresenceSkill .."'")
			GMR.Cast(state.defaultPresenceSkill, "player")
			return
		end
	end

	if spellKnown.vampiricBlood and GMR.GetHealth("player") <= CFG.vampiricBloodHpUse then
		local casted = useSpellWithPreBloodTap(spells.vampiricBlood, "player")
		if casted then
			return
		end
	end

	if spellKnown.runeTap and GMR.GetHealth("player") <= CFG.runeTapHpUse then
		local casted = useSpellWithPreBloodTap(spells.runeTap, "player")
		if casted then
			return
		end
	end

	--dbgPrint("should do stage 2")

	if spellKnown.iceboundFortitude and GMR.IsCastable(spells.iceboundFortitude, "player")
		and GMR.GetHealth("player") <= CFG.iceboundFortitudeHpUse
	then
		dbgPrint("should use icebound fortitude")
		GMR.Cast(spells.iceboundFortitude, "player")
		return
	end

	local targetBloodPlagueDuration = GMR.GetDebuffExpiration("target", spells.bloodPlague)
	local targetFrostFeverDuration = GMR.GetDebuffExpiration("target", spells.frostFever)

	local shouldCastPlagueStrike = false
	local shouldCastIcyTouch = false
	if state.hasGlyphOfDisease then
		if targetBloodPlagueDuration <= 0 then
			shouldCastPlagueStrike = true
		end
		if targetFrostFeverDuration <= 0 then
			shouldCastIcyTouch = true
		end
	else
		if targetBloodPlagueDuration <= 3 then
			shouldCastPlagueStrike = true
		end
		if targetFrostFeverDuration <= 3 then
			shouldCastIcyTouch = true
		end
	end

	if shouldCastPlagueStrike and GMR.IsCastable(spells.plagueStrike, "target")
		and GMR.IsSpellInRange(spells.plagueStrike, "target")
	then
		dbgPrint("renew blood plague debuff with plague strike")
		GMR.Cast(spells.plagueStrike, "target")
		return
	end

	if shouldCastIcyTouch and GMR.IsCastable(spells.icyTouch, "target")
		and GMR.IsSpellInRange(spells.icyTouch, "target")
	then
		dbgPrint("renew frost fever debuff with icy touch")
		GMR.Cast(spells.icyTouch, "target")
		return
	end

	local enemiesToTransferDebuff = 0
	local enemiesWithDebuff = 0
	local enemiesAround = 0
	for i = 1, #GMR.Tables.Attackables do
		local attackable = GMR.Tables.Attackables[i][1]
		-- gather debuff info for pestilence
		if GMR.ObjectExists(attackable) and GMR.GetDistance("player", attackable, "<", state.pestilenceRadius) then
			local attackableBloodPlagueDuration = GMR.GetDebuffExpiration(attackable, spells.bloodPlague)
			local attackableFrostFeverDuration = GMR.GetDebuffExpiration(attackable, spells.frostFever)
			if attackableBloodPlagueDuration < 3 or attackableFrostFeverDuration < 3 then
				enemiesToTransferDebuff = enemiesToTransferDebuff + 1
			else
				enemiesWithDebuff = enemiesWithDebuff + 1
			end
		end

		-- blood boil information gathering
		if GMR.ObjectExists(attackable) and GMR.GetDistance("player", attackable, "<", 10) then
			enemiesAround = enemiesAround + 1
		end
	end

	--dbgPrint("should do stage 3")

	local needToCastPestilenceSpell = false
	if targetBloodPlagueDuration > 3 and targetFrostFeverDuration > 3 and enemiesToTransferDebuff > 0 then
		needToCastPestilenceSpell = true
	elseif state.hasGlyphOfDisease and (targetBloodPlagueDuration > 0 and targetBloodPlagueDuration < 5)
		and (targetFrostFeverDuration > 0 and targetFrostFeverDuration < 5)
	then
		needToCastPestilenceSpell = true
	end

	if needToCastPestilenceSpell and spellKnown.pestilence then
		if GMR.IsCastable(spells.pestilence, "target") then
			dbgPrint("should use Pestilence")
			GMR.Cast(spells.pestilence, "target")
			return
		else
			dbgPrint("wait for possibility of pesilence usage")
		end
	end

	-- we need hp in first place, after that we will use some damage spells
	if GMR.GetHealth("player") < 90 and GMR.IsCastable(spells.deathStrike, "target") and GMR.IsSpellInRange(spells.deathStrike, "target") then
		dbgPrint("should use death strike to heal yourself")
		GMR.Cast(spells.deathStrike, "target")
		return
	end

	if enemiesAround >= CFG.minEnemiesCountToRaiseDead then
		if GMR.IsCastable(spells.raiseDead, "player") and not state.raiseDeadConsumeItem then
			dbgPrint("should use raise dead")
			GMR.Cast(spells.raiseDead)
			return
		end
	end

	if not (needToCastPestilenceSpell and spellKnown.pestilence) then
		local shouldUseBloodFillers = true
		if CFG.useBloodFillersWithBloodRunesOnly and calculateRunes()[RUNETYPE_BLOOD] == 0 then
			shouldUseBloodFillers = false
		end
		if shouldUseBloodFillers then
			local shouldUseBloodBoil = CFG.bloodBoilEnabled and enemiesAround >= CFG.bloodBoilMinEnemies
			if shouldUseBloodBoil and GMR.IsCastable(spells.bloodBoil, "player") then
				dbgPrint("should use blood boil")
				GMR.Cast(spells.bloodBoil, "player")
				return
			end
			if spellKnown.heartStrike then
				if GMR.IsCastable(spells.heartStrike, "target") and GMR.IsSpellInRange(spells.heartStrike, "target") then
					dbgPrint("should use heart strike")
					GMR.Cast(spells.heartStrike, "target")
					return
				end
			else
				if GMR.IsCastable(spells.bloodStrike, "target") and GMR.IsSpellInRange(spells.bloodStrike, "target") then
					dbgPrint("should use blood strike")
					GMR.Cast(spells.bloodStrike, "target")
					return
				end
			end
		end
	end

	-- filler to spent unholy and frost runes
	if spellKnown.deathStrike then
		if GMR.IsCastable(spells.deathStrike, "target") and GMR.IsSpellInRange(spells.deathStrike, "target") then
			dbgPrint("should use death strike as a filler")
			GMR.Cast(spells.deathStrike, "target")
			return
		end
	else
		if GMR.IsCastable(spells.plagueStrike, "target") and GMR.IsSpellInRange(spells.plagueStrike, "target") then
			dbgPrint("should use plague strike as a filler")
			GMR.Cast(spells.plagueStrike, "target")
			return
		end

		if GMR.IsCastable(spells.icyTouch, "target") and GMR.IsSpellInRange(spells.icyTouch, "target") then
			dbgPrint("should use icy touch as a filler")
			GMR.Cast(spells.icyTouch, "target")
			return
		end
	end

	if not GMR.HasBuff("player", spells.hornOfWinter) and GMR.IsCastable(spells.hornOfWinter, "player")
		and GetSpellCooldown(spells.hornOfWinter) == 0
	then
		dbgPrint("should use horn of winter")
		GMR.Cast(spells.hornOfWinter, "player")
		return
	end

	--dbgPrint("do nothing")
end

-- turn on only for death knight class
if shouldLaunch then
	if CFG.useCombatRotationLauncher then
		GMR.CustomCombatConditions = combatRotation
	else
		C_Timer.NewTicker(0.1, function()
			if (not GMR.IsExecuting() or not GMR.IsAlive()) then
				return
			end

			combatRotation()
		end)
	end

	GMR.Print("Death Knight/Blood combat rotation turned ON")
end