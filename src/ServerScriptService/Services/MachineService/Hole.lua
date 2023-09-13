local Hole = {}
Hole.__index = Hole

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

local Ragdoll = require(ServerScriptService.Server.Classes.Ragdoll)

Hole.AvailableInstances = {
    game.Workspace.PlaceModels:FindFirstChild("Hole")
}

function Hole:StartFall(plr)
    local ragdoll = Ragdoll.GlobalRagdolls[plr]
    ragdoll:Toggle(true)
    ragdoll:EditCanRagdoll(false)
end

function Hole:KillPlr(plr)
    if not plr.Character then return end
    plr.Character.Humanoid.Health = 0
end

function Hole:Enable()
    self._trove:Connect(RunService.Heartbeat, function(dt)
        local parts = game.Workspace:GetPartsInPart(self.Instance.Hitbox, self.MachineFuncs.GetHitboxParams())
        local parts2 = game.Workspace:GetPartsInPart(self.Instance.DeathHitbox, self.MachineFuncs.GetHitboxParams())

        local doneChrs = {} -- probably only need 1 because you cant be in both at once (?)

        for _, part in ipairs(TableUtil.Extend(parts, parts2)) do
            local chr = part.Parent
            local plr = game.Players:GetPlayerFromCharacter(chr)
            if not plr or table.find(doneChrs, chr) then return end
            
            table.insert(doneChrs, chr)
            
            task.spawn(function()
                if table.find(parts, part) then
                    self:StartFall(plr)
                else
                    self:KillPlr(plr)
                end
            end)
        end
    end)
end

function Hole:Start()
    self:Enable()    
end

function Hole.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(Hole.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,
        
        _trove = Trove.new()
    }), Hole)

    print("new hole")

    return self
end

return Hole