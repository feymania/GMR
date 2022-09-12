JudgementofWisdom = GetSpellInfo(53408)
JudgementofLight = GetSpellInfo(20271)
JudgementofJustice = GetSpellInfo(53407)    
  
C_Timer.NewTicker(0.1, function()
  if UnitClass("player") == "Paladin" then
    if GMR.IsExecuting() and GMR.InLoS("target") and UnitExists("target") and IsUsableSpell(JudgementofWisdom) and GMR.GetDistance("player", "target", "<", 10) then
		GMR.Cast(JudgementofWisdom)
    end
  end
end)
