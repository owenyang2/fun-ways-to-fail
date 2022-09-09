local Volcano = {}
Volcano.__index = Volcano

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Trove = require(RepStorage.Packages.Trove)

Volcano.AvailableInstances = { -- available presses
    game.Workspace.PlaceModels:FindFirstChild("Volcano")
}

function Volcano:Burn(chr)
    
end

function Volcano:Enable()
    local chrList = {}

    self._trove:Connect(RunService.Heartbeat, function(dt)
        local parts = game.Workspace:GetPartsInPart(self.Instance.Lava, self:GetHitboxParams())

        local doneChrs = {}

        for _, part in ipairs(parts) do
            local chr = part.Parent
            if not game.Players:GetPlayerFromCharacter(chr) or table.find(doneChrs, chr) then return end
            
            table.insert(doneChrs, chr)

            if not chrList[chr] then chrList[chr] = {StayLength = 0} continue end

            chrList[chr].StayLength += dt

            if chrList[chr].StayLength > self.Config.BurnDelay then
                self:Burn(chr)
            end
        end
    end)
end

function Volcano:Disable()
    self._trove:Clean()
end

function Volcano:Start()
    self:Enable()    
end

function Volcano.new()
    local newInst = Volcano:GetAvailableInst()
    if not newInst then return end

    local Volcano = setmetatable({
        Instance = newInst,
        
        _trove = Trove.new(),

        Config = {
            BurnDelay = 1, -- how long until player starts burning
            TurnRedTime = 3,
        }
    }, Volcano)

    return Volcano
end

return Volcano