local HUD = {}
HUD.__index = HUD

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

function HUD:SetupDeaths()
    local deathsUI = self.hudUI.Left.DeathCount.Deaths.Value
    local deathsServer = self.Player:WaitForChild("leaderstats").Deaths

    deathsUI.Text = self.UIFuncs.AbbreviateNumber(deathsServer.Value) -- init when first join

    deathsServer.Changed:Connect(function(newValue)
        deathsUI.Text = self.UIFuncs.AbbreviateNumber(newValue)
    end)
end

function HUD:Start()
    self:SetupDeaths()    
end

function HUD.new(baseTbl)
    --[[ 
    baseTbl comes with:
        UIFuncs : ModuleScript
        MainUI : ScreenGui
        Player : Player
    --]]

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        hudUI = baseTbl.MainUI.HUD,

        _trove = Trove.new()
    }), HUD)

    return self
end

return HUD