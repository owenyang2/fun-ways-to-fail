local Piranhas = {}
Piranhas.__index = Piranhas

local PiranhaClass = require(script.Parent.Parent.Classes.PiranhaClass)

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

Piranhas.AvailableInstances = {
    game.Workspace.PlaceModels:FindFirstChild("Piranhas")
}

function Piranhas:SpawnPiranhas()
    local template = RepStorage.Assets.Piranha

    for i = 1, self.PiranhasToSpawn do
        local inst = template:Clone()
        inst.Parent = self.Instance.Fish

        local p = PiranhaClass.new(inst, self.Instance)

        table.insert(self.Piranhas, p)
    end
end

function Piranhas:Start()
    self:SpawnPiranhas()

    self._trove:Connect(RunService.Heartbeat, function(dt) -- in the future, maybe use perlin noise to make fish swim left/right, up/down random
        for _, p in ipairs(self.Piranhas) do
            if p.Deg == 360 then
                p.Deg = 0
            end

            local x = p.Radius * math.cos(math.rad(p.Deg))
            local z = p.Radius * math.sin(math.rad(p.Deg))

            p.AlignPosition.Position = self.Instance.Water.Position + Vector3.new(-x, 0, -z) + p.Offset
            p.AlignOrientation.CFrame = CFrame.Angles(0, math.rad(-p.Deg), 0)
            
            p.Deg += p.DegInc
        end
    end)
end

function Piranhas.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(Piranhas.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,
        Piranhas = {},
        PiranhasToSpawn = 30,

        _trove = Trove.new()
    }), Piranhas)

    return self
end

return Piranhas