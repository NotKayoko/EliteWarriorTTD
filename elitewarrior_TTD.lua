local lastCheckTime = 0;
local checkInterval = 0.2;
EliteWarrior.TTD = CreateFrame("Frame", nil, UIParent);

local inCombat = false;

local textTimeTillDeath = UIParent:CreateFontString(nil,"OVERLAY","GameTooltipText")
textTimeTillDeath:SetFont("Fonts\\FRIZQT__.TTF", 99, "OUTLINE, MONOCHROME")
local textTimeTillDeathText = UIParent:CreateFontString(nil,"OVERLAY","GameTooltipText")
textTimeTillDeathText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE, MONOCHROME")

-- Globals Section
local timeSinceLastUpdate = 0;
local combatStart = GetTime();

local function TTD_Show()
    if (inCombat) then
        textTimeTillDeath:SetPoint("BOTTOMLEFT", math.floor(GetScreenWidth()*.475), math.floor(GetScreenHeight()*.11));
        textTimeTillDeathText:SetText("Time Till Death:");
        local point, relativeTo, relativePoint, xOfs, yOfs = textTimeTillDeath:GetPoint();
        textTimeTillDeathText:SetPoint("BOTTOMLEFT", xOfs, yOfs+28);
    end
end
local function TTD_Hide()
    battleShoutIcon:Hide();
    textTimeTillDeath:SetText("-.--");
end

-- TTD stands for Time Till Death
local function TTDLogic()
    if UnitIsEnemy("player","target") or UnitReaction("player","target") == 4 then
        local EHealthPercent = UnitHealth("target")/UnitHealthMax("target")*100;
        if EHealthPercent == 100 then
            if targetName ~= 'Spore' and targetName ~= 'Fallout Slime' and targetName ~= 'Plagued Champion' then
                -- may not want to restart combat if you tab to one of these monsters
                combatStart = GetTime();
            end
        end;
        if EHealthPercent then
            local maxHP     = UnitHealthMax("target");
            local targetName = UnitName("target");
            if targetName == 'Vaelastrasz the Corrupt' then
                maxHP = UnitHealthMax("target")*0.3;
            end;
            local curHP     = UnitHealth("target");
            local missingHP = maxHP - curHP;
            local seconds   = timeSinceLastUpdate - combatStart; -- current length of the fight
            remainingSeconds = (maxHP/(missingHP/seconds)-seconds)*0.90; -- Should prob make it count the number of warriors in the raid
            if (remainingSeconds ~= remainingSeconds) then
                textTimeTillDeath:SetText("-.--")
            else
                if (remainingSeconds) then
                    textTimeTillDeath:SetText(string.format("%.2f",remainingSeconds));
                end
            end
        end
    end
end

function onUpdate(sinceLastUpdate)
    timeSinceLastUpdate = GetTime();
    if GetTime()-lastCheckTime >= checkInterval then
        if (lastCheckTime == 0) then
            lastCheckTime = GetTime();
        end
        TTDLogic();

        lastCheckTime = 0;
    end
end
EliteWarrior.TTD:SetScript("OnUpdate", function(self) if inCombat then onUpdate(timeSinceLastUpdate); end; end);

EliteWarrior.TTD:SetScript("OnShow", function(self)
    timeSinceLastUpdate = 0
end)


EliteWarrior.TTD:SetScript("OnEvent", function()
    if event == "PLAYER_REGEN_DISABLED" then
        combatStart = GetTime();
        inCombat = true;
        TTD_Show();
    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false;
        combatStart = GetTime();
        TTD_Hide();
        combatStart = GetTime();
        textTimeTillDeathText:SetText("");
    elseif event == "PLAYER_DEAD" then
        inCombat = false;
    end
end);
EliteWarrior.TTD:RegisterEvent("PLAYER_REGEN_ENABLED");
EliteWarrior.TTD:RegisterEvent("PLAYER_REGEN_DISABLED");
EliteWarrior.TTD:RegisterEvent("PLAYER_DEAD");