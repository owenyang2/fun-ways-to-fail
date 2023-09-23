local IceLake = {}
IceLake.__index = IceLake

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")
local PhysicsService = game:GetService("PhysicsService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

local Ragdoll = require(ServerScriptService.Server.Classes.Ragdoll)

local MachineFolder = game.Workspace.PlaceModels["Frozen Lake"]

IceLake.AvailableInstances = {
    game.Workspace.PlaceModels:FindFirstChild("Frozen Lake")
}

function IceLake:CheckFall(dt)
    for ice, _ in pairs(self.IceParts) do
        local info = self.IceParts[ice]

        if info.Fallen then
            info.Time += dt

            if info.Time < self.Presets.RespawnTime * 2 then continue end -- idk why but its not being exact, just add a bit more because idk
            
            info.FakeIce:Destroy()
            info.FakeIce = nil

            info.Time = 0
            ice.Transparency = 0.5
            ice.CanCollide = true

            info.Fallen = false
        else
            local parts = workspace:GetPartsInPart(info.Hitbox, self.MachineFuncs.GetHitboxParams())
            
            if #parts > 0 then
                info.Time += dt
                if info.Time >= self.Presets.FallDelay then
                    info.Time = 0

                    info.FakeIce = ice:Clone()
                    info.FakeIce.Anchored = false
                    info.FakeIce.Parent = self.Instance.FakeIce

                    PhysicsService:SetPartCollisionGroup(info.FakeIce, self.COLLISION_GROUP)

                    ice.Transparency = 1
                    ice.CanCollide = false
                    info.Fallen = true    
                end
            else
                info.Time = 0
            end
        end
    end
end

function IceLake:CheckWater()
    local parts = workspace:GetPartsInPart(self.Instance.FreezingWater, self.MachineFuncs.GetHitboxParams())

    local didChrs = {}

    for _, part in ipairs(parts) do
        local chr = part:FindFirstAncestorWhichIsA("Model")

        if table.find(didChrs, chr) then
            continue
        end

        table.insert(didChrs, chr)

        if not table.find(self.FreezingChrs, chr) then
            table.insert(self.FreezingChrs, chr)
            chr.Humanoid.WalkSpeed = self.Presets.WalkSpeed
            
            for _, color in ipairs(self.BodyColors) do
                self.OrigColors[chr] = chr["Body Colors"][color]
                chr["Body Colors"][color] = self.FreezeColor
            end

            self.KillTween[chr] = TweenService:Create(chr.Humanoid, TweenInfo.new(
                self.Presets.KillTime / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.In
            ), {Health = 50})
            self.KillTween[chr]:Play()

            self.KillTween[chr].Completed:Connect(function(playbackState)
                print(playbackState)
                if playbackState == Enum.PlaybackState.Completed then
                    for _, part in ipairs(chr:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Anchored = true
                        end
                    end

                    local iceCube = RepStorage.Assets.IceCube:Clone()
                    iceCube.CFrame = chr.HumanoidRootPart.CFrame
                    iceCube.Parent = chr
                    
                    local weldConst = Instance.new("WeldConstraint")
                    weldConst.Name = "IceCube"
                    weldConst.Part0 = iceCube
                    weldConst.Part1 = chr.HumanoidRootPart
                    weldConst.Parent = chr

                    self.KillTween[chr] = TweenService:Create(chr.Humanoid, TweenInfo.new(
                        self.Presets.KillTime / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.In
                    ), {Health = 0})
                    self.KillTween[chr]:Play()
                end
            end)
        end
    end

    for i, chr in ipairs(self.FreezingChrs) do
        if not chr or not chr:FindFirstChild("Humanoid") or chr.Humanoid.Health == 0 then
            table.remove(self.FreezingChrs, i)
            continue
        end

        if not table.find(didChrs, chr) then
            table.remove(self.FreezingChrs, i)
            chr.Humanoid.WalkSpeed = 16
            self.KillTween[chr]:Pause()

            for _, color in ipairs(self.BodyColors) do
                chr["Body Colors"][color] = self.OrigColors[chr]
            end
        end
    end
end

function IceLake:Start()
    RunService.Heartbeat:Connect(function(dt)
        self:CheckFall(dt)
        self:CheckWater()
    end)
end

function IceLake.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(IceLake.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,
        IceParts = {},
        Presets = {
            FallDelay = 1,
            RespawnTime = 10,
            WalkSpeed = 5,
            KillTime = 5
        },
        COLLISION_GROUP = "Ice",
        FreezingChrs = {},
        OrigColors = {},
        KillTween = {},

        _trove = Trove.new(),

        BodyColors = {
            "HeadColor3",
            "LeftArmColor3",
            "RightArmColor3",
            "LeftLegColor3",
            "RightLegColor3",
            "TorsoColor3"
        },

        FreezeColor = Color3.fromRGB(0, 150, 255),

    }), IceLake)

    PhysicsService:CreateCollisionGroup("Snow")
    PhysicsService:CreateCollisionGroup(self.COLLISION_GROUP)

    for _, ice in ipairs(MachineFolder:GetChildren()) do
        if ice.Name == "Ice" then
            local hitbox = ice:Clone()
            hitbox.Transparency = 1
            hitbox.CanCollide = false
            hitbox.Anchored = true

            hitbox.Name = "Hitbox"
            hitbox.Size = hitbox.Size + Vector3.new(0, 2, 0)
            hitbox.Parent = ice

            self.IceParts[ice] = {Time = 0, Hitbox = hitbox, FakeIce = nil, Fallen = false}        
        end
        
        --[[ -- from previous ice lake model
        elseif ice.Name == "Snow" then
            PhysicsService:SetPartCollisionGroup(ice, "Snow")
        end
        --]]
    end

    PhysicsService:CollisionGroupSetCollidable(self.COLLISION_GROUP, "Players", false)
    --PhysicsService:CollisionGroupSetCollidable(self.COLLISION_GROUP, "Snow", false) -- now obsolete

    self:Start()

    return self
end

return IceLake