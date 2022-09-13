-- AlteracValleyClustering
-- Author: Mons#0885
-- Version: 0.1.0
-- Description: Better Alterac Valley experience
-- Usage: run with mons_alterac_valley profile for unstucks and better experience 

-- user variables
local CFG = {
    updateTimer = 8,
    debug = true
}
-- TODO List
-- Drek Condition
-- Better Cluster scoring system
    -- Distance to boss
    -- Distance from current clusterUnit ( a big distance might be bad )
-- More unstucks
-- More blacklists
-- More love to the horde experience
-- Tinkr users apparently have lots of crashes due to scan of players
-- Will unconditionally just run in and attack drek 
-- Option to target what clusterUnit is targeting if unit is in combat

local function dbgPrint(msg)
	if not CFG.debug then
		return
	end

	local message = "[DEBUG] " .. msg
	GMR.Print(message)
	GMR.Log(message)
end

function GMR.IsValidClusterPosition(x, y, z)
    local faction, _ = GMR.GetFaction("player")
    local isAlliance = true

    if faction == "Horde" then
        isAlliance = false
    end

    battlegroundsAlliance = {
        ["Alterac Valley"] = {
            -- Graveyards
            {-162.663, 27.024, 77.04,30} ,-- Snowfall GY
            {73.132, -496.766, 48.726,30}, -- Stonehearth GY
            { 212.868, -364.971, 42.396, 30 }, -- Icewing bunker
            { -571.584, -262.509, 68.469, 20}, -- Iceblood Tower
            { -768.397, -362.27, 84.355, 20 }, -- Tower Point
            {-143.833, -454.627, 26.384,35}, -- Stonehearth Bunker
            {-945.605, -122.969, 78.457, 150}, -- Coldtooth mine
            {758.323, -488.956, 96.015, 40}, --Alliance Gatee
            {712.367, -14.763, 50.135, 70}, -- Vans room ( no reason to be here as alliance )
            {869.114, -496.138, 96.623,70}, -- Cave graveyard
            {274.533, 53.15, 20.618,70},-- weird cave  
            {676, -374, 29.781, 40} -- stormpike graveyard 
        }
    }
    battlegroundsHorde = {
        ["Alterac Valley"] = {
            -- Graveyards  
            {-530.869, -403.828, 49.508, 50}, -- Horde IB GY 
            {-1087.025, -251.577, 57.765, 50 }, -- Frostwolf Horde GY
            {-1496.516, -332.333, 101.128,50}, -- Frostwolf relief GY
            {-162.663, 27.024, 77.04,50} ,-- Snowfall BY
            { 212.868, -364.971, 42.396, 50 }, -- Icewing bunker
            { -571.584, -262.509, 68.469, 50}, -- Iceblood Tower
            { -768.397, -362.27, 84.355, 50 }, -- Tower Point
            {-945.605, -122.969, 78.457, 150}, -- Coldtooth mine
            {-143.833, -454.627, 26.384,35}, -- Stonehearth Bunker
            {-1376.314, -540.64, 55.059,15}, -- Horde gate
            {-1430.172, -591.198, 51.182,60},-- Horde Cave GY
            {-1528.109, -458.579, 69.451,100}, -- Horde Cave
            {-531.498, -402.881, 49.537,30} -- Iceblood GY
        }}
    local bgInfo = GMR.GetBattlegroundInfo()
    if bgInfo then
        local blacklist = {}
        if isAlliance and battlegroundsAlliance[bgInfo.Name] then
            blacklist = battlegroundsAlliance[bgInfo.Name]
        elseif not isAlliance and battlegroundsHorde[bgInfo.Name] then
            blacklist = battlegroundsHorde[bgInfo.Name]
        end

        for i = 1, #blacklist do
            local bX, bY, bZ, bRadius = blacklist[i][1], blacklist[i][2], blacklist[i][3], blacklist[i][4]
            if GMR.GetDistanceBetweenPositions(x, y, z, bX, bY, bZ) <= bRadius then
                return false
            end
        end
    end
    return true
end
function GMR.GetNearestPartyPlayerCluster()
    local countMembers, countEnemies, clusterUnit = 0, 0, nil
    local partyType, partyMemberMax
    local faction, _ = GMR.GetFaction("player")
    local isAlliance = true
    if faction == "Horde" then
        isAlliance = false
    end

    if UnitInRaid("player") then
        partyType, partyMemberMax = "raid", UnitInRaid("player") * 5
    elseif UnitInParty("player") then
        partyType, partyMemberMax = "party", 5
    end
    if not partyType then
        return
    end
    -- save all cluster units that does not make us go "backwards"
    local bestClusterUnits = {}
    for i = 1, partyMemberMax do
        local unit = partyType .. i
        if not UnitExists(unit) then
            break
        end
        -- If clusterUnit is not ourself, a ghost and it exists 
        if not UnitIsDeadOrGhost(unit) and not UnitIsUnit("player", unit) and GMR.ObjectExists(unit) then
            local membersAroundUnit = GMR.GetNumPartyMembersAroundUnit(unit)
            local enemiesAroundUnit = GMR.GetNumEnemyPlayersAroundUnit(unit)

            -- This adds all valid clusterUnits
            countMembers, clusterUnit = membersAroundUnit, unit
            if clusterUnit then
                local cY, cX, cZ = GMR.ObjectPosition(clusterUnit)
                local pY, _,_ = GMR.ObjectPosition("player")
                local isValid = GMR.IsValidClusterPosition(cY,cX,cZ)
                if isValid then
                    if clusterUnit and cY and pY then
                        table.insert(bestClusterUnits,
                            { countMembers = countMembers, countEnemies = countEnemies, clusterUnit = clusterUnit, distY = cY, memberRatio=(countMembers+1) / (enemiesAroundUnit+1) })
                    end
                end
            end
        end
    end

    local bestClusterUnit = nil
    for k, v in pairs(bestClusterUnits) do
        if bestClusterUnit == nil and v then
            bestClusterUnit = v
        else
            -- Here we can do some scoring of the clusters.
            -- In initial testing i thought clusters closer to south was better, its actually not
            -- Clusters that are big in comparison to enemies are much better for honor, doesnt matter where they are
            
            -- If cluster has more members or better member to enemy ratio
            if v.countMembers >= bestClusterUnit.countMembers or v.memberRatio >= bestClusterUnit.memberRatio then
                
                -- Figure out a good weight for size versus ratio. 
                local dRatio = v.memberRatio - bestClusterUnit.memberRatio
                local dCount = v.countMembers - bestClusterUnit.countMembers

                local score = dRatio * 2 + dCount
                local cu_currentSpeed, cu_maxRunSpeed = GMR.GetUnitSpeed(v.clusterUnit)
                -- Dont pick a NEW clusterUnit thats standing still
                if score > 0 and cu_currentSpeed > 0 then
                    bestClusterUnit = v
                end
            end     
        end
    end
    if bestClusterUnit ~= nil and GMR.ObjectPosition(bestClusterUnit.clusterUnit) then
        return GMR.ObjectPointer(bestClusterUnit.clusterUnit), bestClusterUnit.countMembers,
            bestClusterUnit.countEnemies
    else
        return nil,0,0
    end
end

-- Hook the GMR.UpdateBattlegroundCluster() function
function GMR.UpdateBattlegroundCluster()
    local preparationOnPlayer = AuraUtil.FindAuraByName(GetSpellInfo(44521), "player", "HELPFUL")
    
    -- Reset cluster unit WITHOUT delay, if blacklisted
    if GMR.Variables.ClusterUnit then
        local cY, cX, cZ = GMR.ObjectPosition( GMR.Variables.ClusterUnit)
        if not GMR.IsValidClusterPosition(cY,cX,cZ) then
            dbgPrint("Clearing clusterUnit not valid position")
            GMR.Variables.ClusterUnit = nil;
            GMR.Log("RESET_CLUSTER_UNIT")
        end
        -- Alliance AFK hill
        local drX,drY,drZ = -1347.232, -306.648, 94.541
        if GMR.IsPlayerPosition(drX, drY, drZ, 20) and not GMR.GetDelay("RandomMovementDice") then
            -- If we are on the drek afk hill clear the clusterUnit
            dbgPrint("Clearing clusterUnit - Drek AFK hill condition")
            GMR.SetDelay("RandomMovementDice", 5)
            GMR.SetDelay("DenyBattlegroundDefaultPath", 6);
            local dice = math.random(1, 4)
            bg_actions[dice]()
            GMR.Variables.ClusterUnit = nil;
        end
    end
     
    if not GMR.GetDelay("DefineCluster") and GMR.IsInBattleground() and not GMR.IsBattlegroundFinished() and
        not preparationOnPlayer then
        GMR.SetDelay("DefineCluster", CFG.updateTimer)
        if GMR.Variables.ClusterUnit then

            local clusterUnit, countMembers, countEnemies = GMR.GetNearestPartyPlayerCluster() -- This function is also hooked
            local membersAroundClusterUnit = GMR.GetNumPartyMembersAroundUnit(GMR.Variables.ClusterUnit)
            local enemiesAroundClusterUnit = GMR.GetNumEnemyPlayersAroundUnit(GMR.Variables.ClusterUnit)
            if (not GMR.Variables.ClusterUnit
                or not GMR.ObjectPosition(GMR.Variables.ClusterUnit)
                or GMR.UnitIsDeadOrGhost(GMR.Variables.ClusterUnit)
                or membersAroundClusterUnit < 2
                or (countMembers and membersAroundClusterUnit + 2 < countMembers)
                or (enemiesAroundClusterUnit == 0 and countEnemies and countEnemies > 0)) then
                if clusterUnit then
                    GMR.Variables.ClusterUnit = clusterUnit;
                    GMR.SetDelay("DenyBattlegroundDefaultPath", 3);
                    GMR.Log("DEFINE_CLUSTER_UNIT")
                else
                    dbgPrint("Clearing clusterUnit")
                    GMR.Variables.ClusterUnit = nil;
                    GMR.Log("RESET_CLUSTER_UNIT")
                end
            end
           
        else
            local clusterUnit, countMembers, countEnemies = GMR.GetNearestPartyPlayerCluster()
            if clusterUnit and not preparationOnPlayer then
                GMR.Variables.ClusterUnit = clusterUnit;
                GMR.SetDelay("DenyBattlegroundDefaultPath", 3);
                GMR.Log("DEFINE_CLUSTER_UNIT")
            end
        end
        
    end
end

-- String multiple dices together for a vector of random inputs
bg_actions = {
    [1] = function(x)
        dbgPrint("Moving forwards")
        GMR.MoveForwardStart()
        C_Timer.After(3, GMR.MoveForwardStop)
    end,
    [2] = function(x)
        dbgPrint("Turning left")
        GMR.MoveForwardStart()
        GMR.TurnLeftStart()
        C_Timer.After(1, GMR.TurnLeftStop)
        C_Timer.After(3, GMR.MoveForwardStop)
    end,
    [3] = function(x)
        dbgPrint("Turning right")
        GMR.MoveForwardStart()
        GMR.TurnRightStart()
        C_Timer.After(1, GMR.TurnRightStop)
        C_Timer.After(3, GMR.MoveForwardStop)
    end,
    [4] = function(x)
        dbgPrint("Jumping")
        GMR.Jump()
    end,
}

-- start the main loop ( starts when preparation buff is not present )
dbgPrint("Loaded Mons BG Plugin")
local faceClusterunit = false
local avGateFlag = false
C_Timer.NewTicker(0.5, function()
    if GMR.IsInBattleground() and GetZoneText() == "Alterac Valley" then
        local player = GMR.GetPlayerPointer("player")
        local clusterUnit = GMR.Variables.ClusterUnit
        local preparationOnPlayer = AuraUtil.FindAuraByName(GetSpellInfo(44521), "player", "HELPFUL")

        if clusterUnit and player and not preparationOnPlayer then

            
            GMR.FocusUnit(clusterUnit)

            -- Target clusterunits target if clusterunit is in combat
            --if GMR.InCombat(clusterUnit) and GMR.ObjectTarget(clusterUnit) then
            --    dbgPrint("Clusterunit is in combat, and targeting someone")
            --    GMR.TargetUnit(GMR.ObjectTarget(clusterUnit))
            --end

            local clusterUnitName, _ = GMR.UnitName(clusterUnit)
            local cu_currentSpeed, cu_maxRunSpeed = GMR.GetUnitSpeed(clusterUnit)
            local distanceToClusterUnit = GMR.GetDistanceBetweenObjects(player, clusterUnit)

            local cu_spellName, _, _, cu_castingTimeStart, cu_castingTimeEnd = GMR.UnitCastingInfo("focus")
            -- Dismount if within mounting range of clusterUnit, and clusterUnit is dismounted
            if cu_maxRunSpeed and distanceToClusterUnit then
                if cu_maxRunSpeed < 9.0 and distanceToClusterUnit < GMR.GetGroundMountingRange() then
                    if IsMounted("player") then
                        Dismount()
                    end
                end
                if cu_maxRunSpeed > 9.0 and not IsMounted("player") and
                    distanceToClusterUnit < GMR.GetGroundMountingRange() and not GMR.InCombat(player) and IsOutdoors() then
                    dbgPrint("Casting mount")
                    GMR.SetDelay("DefineCluster", 4)
                    CastSpellByName(GMR_SavedVariablesPerCharacter.SelectedMount)
                end
                -- If we are close to the clusterUnit, and the clusterUnit is standing still, we initialize
                -- the random movement block
                -- Its a random dice throw between 4 actions we repeat twice
                -- Its pretty jank but i think its okay
                if cu_currentSpeed and cu_currentSpeed < 1.0 and distanceToClusterUnit < 20.0 and
                    not GMR.InCombat(player) then

                    if not faceClusterunit and distanceToClusterUnit < 7.0 then
                        -- If we are right on the clusterUnit, face away
                        dbgPrint("bg_plugin: facing clusterUnit and turning away")
                        GMR.FaceDirection(clusterUnit)
                        C_Timer.After(0.5, GMR.MoveBackwardStart)
                        C_Timer.After(0.8, GMR.TurnRightStart)

                        C_Timer.After(1.8, GMR.TurnRightStop) -- 180 turn
                        C_Timer.After(2.0, GMR.MoveBackwardStop)
                        faceClusterunit = true

                    end
                end
            else
                faceClusterunit = false
            end
        end
    else
        GMR.ClearFocus()
    end
end)
