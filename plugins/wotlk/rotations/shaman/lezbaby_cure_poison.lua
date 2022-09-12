C_Timer.NewTicker(0.5, function()
	if not GMR.IsExecuting() or GMR.UnitIsDeadOrGhost("player") then 
		return 
	end 
	if GMR.GetClass("player") == "SHAMAN" then
        local spell = 526
        local debuff = 32902
        if not IsMounted()
        and not IsFlying()
        and not GMR.IsRecovering()
        and GMR.InCombat()
        and GMR.IsCastable(spell)
        and not GMR.HasBuff("player", GetSpellInfo(buff))
        and GMR.IsAlive() then
            GMR.Cast(spell, "player")
        end
    end
end)