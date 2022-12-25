local IceLake = {}
IceLake.__index = IceLake

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

local Ragdoll = require(ServerScriptService.Server.Classes.Ragdoll)

local MachineFolder = game.Workspace.PlaceModels["Frozen Lake"]

IceLake.AvailableInstances = {
    game.Workspace.PlaceModels:FindFirstChild("Frozen Lake")
}

local function getOverlapParams()
    local op = OverlapParams.new()
    op.FilterType = Enum.RaycastFilterType.Whitelist

    local t = {}

    for _, plr in ipairs(game.Players:GetPlayers()) do
        table.insert(t, plr.Character)
    end

    op.FilterDescendantsInstances = t
    
    return op
end

function IceLake:Start()
    RunService.Heartbeat:Connect(function(dt)
        for ice, _ in pairs(self.IceParts) do
            if table.find(self.Fallen, ice) then
                self.IceParts[ice] += dt

                if self.IceParts[ice] < self.Presets.RespawnTime then continue end
                
                self.IceParts[ice] = 0
                ice.Transparency = 0.5
                ice.CanCollide = true
                table.remove(self.Fallen, table.find(self.Fallen, ice))
            else
                local parts = workspace:GetPartsInPart(ice, getOverlapParams())
                print(parts)
                if #parts > 0 then
                    self.IceParts[ice] += dt
                    print(self.IceParts[ice])
                    if self.IceParts[ice] >= self.Presets.FallDelay then
                        self.IceParts[ice] = 0
                        ice.Transparency = 1
                        ice.CanCollide = false
                        table.insert(self.Fallen, ice)    
                    end
                else
                    self.IceParts[ice] = 0
                end
            end
        end
    end)
end

function IceLake.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(IceLake.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,
        IceParts = {},
        Fallen = {},
        Presets = {
            FallDelay = 1,
            RespawnTime = 10,
        },

        _trove = Trove.new()
    }), IceLake)

    for _, ice in ipairs(MachineFolder:GetChildren()) do
        if ice.Name == "Ice" then
            self.IceParts[ice] = 0
        end
    end

    self:Start()

    return self
end

return IceLake