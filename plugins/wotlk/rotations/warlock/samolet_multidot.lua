function GMR.CustomCombatConditions()
	local class = GMR.GetClass("player")
	if class == "WARLOCK" then
	local Corruption = GetSpellInfo(47813)
	local Curse_of_Agony = GetSpellInfo(47864)
	local Unstable_Affliction = GetSpellInfo(30405)
		for i = 1, #GMR.Tables.Attackables do
		local attackable = GMR.Tables.Attackables[i][1]
			if GMR.ObjectExists(attackable)
			and GMR.IsCastable(Corruption)
			and GMR.GetDistance("player", attackable, "<", 30)
			and not AuraUtil.FindAuraByName(Corruption, attackable, "HARMFUL")
			and UnitAffectingCombat(attackable) then
				GMR.Cast(Corruption, attackable)
			end
		end
		for i = 1, #GMR.Tables.Attackables do
		local attackable = GMR.Tables.Attackables[i][1]
			if GMR.ObjectExists(attackable)
			and GMR.IsCastable(Curse_of_Agony)
			and GMR.GetDistance("player", attackable, "<", 30)
			and not AuraUtil.FindAuraByName(Curse_of_Agony, attackable, "HARMFUL")
			and UnitAffectingCombat(attackable) then
				GMR.Cast(Curse_of_Agony, attackable)
			end
		end
--		for i = 1, #GMR.Tables.Attackables do
--		local attackable = GMR.Tables.Attackables[i][1]
--			if GMR.ObjectExists(attackable)
--			and GMR.IsCastable(Unstable_Affliction)
--			and GMR.GetDistance("player", attackable, "<", 35)
--			and not AuraUtil.FindAuraByName(Unstable_Affliction, attackable, "HARMFUL") then
--				GMR.Cast(Unstable_Affliction, attackable)
--			end
--		end
	end
end
