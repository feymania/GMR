Slam = GetSpellInfo(47475)

C_Timer.NewTicker(0.1, function()
  if UnitClass("player") == "Warrior" then
    if not mounted and GMR.IsExecuting() and GMR.InLoS("target") and UnitExists("target") then
      if AuraUtil.FindAuraByName("Slam!", "player", "HELPFUL") then
        if GetSpellInfo(Slam) and IsUsableSpell(Slam) then
          GMR.Cast(Slam)
        end
      end
    end
  end
end)