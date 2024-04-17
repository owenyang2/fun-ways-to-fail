local Potion = {}
Potion.__index = Potion

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)
local Knit = require(RepStorage.Packages.Knit)

local Ragdoll = require(ServerScriptService.Server.Classes.Ragdoll)

Potion.AvailableInstances = {
    game.Workspace.PlaceModels:FindFirstChild("Potion")
}

function Potion:Drink(plr)
    local colors = {
        Color3.fromRGB(255, 242, 0),
        Color3.fromRGB(22, 172, 22),
        Color3.fromRGB(255, 0 , 0)
    }
    local num = math.random(1, 3)
    
    if num == 1 then
        plr.Character.Humanoid.BodyDepthScale.Value = 0.8
        plr.Character.Humanoid.BodyHeightScale.Value = 0.8
        plr.Character.Humanoid.BodyWidthScale.Value = 0.8
        plr.Character.Humanoid.HeadScale.Value = 2
    elseif num == 2 then
        plr.Character.RagdollJoints.LeftShoulder.Enabled = true
        plr.Character.RagdollJoints.RightShoulder.Enabled = true
        plr.Character.RagdollJoints.LeftShoulder:SetAttribute("CantEdit", true)
        plr.Character.RagdollJoints.RightShoulder:SetAttribute("CantEdit", true)
    else
        plr.Character.Humanoid.WalkSpeed = 40
        
        task.spawn(function()
            while plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 do
                plr.Character.Humanoid.Health -= 1
                print(plr.Character.Humanoid.Health)
                task.wait(0.1)
            end
        end)
    end

    local color = colors[num]

    local bc = plr.Character["Body Colors"]
    bc.HeadColor3 = color
    bc.LeftArmColor3 = color
    bc.LeftLegColor3 = color
    bc.RightArmColor3 = color
    bc.RightLegColor3 = color
    bc.TorsoColor3 = color
end

function Potion:Start()
    self.Instance.Potion.ProximityPrompt.Triggered:Connect(function(plr)
        local newPotion = RepStorage.Assets.Potion:Clone()
        newPotion.Parent = plr.Character
        newPotion.Anchored = false
        newPotion.CFrame = plr.Character.RightHand.CFrame + (plr.Character.RightHand.CFrame.UpVector * -0.5)
        newPotion.CFrame *= CFrame.Angles(math.rad(270), 0, 0)
        
        local newWeld = Instance.new("WeldConstraint")
        newWeld.Part0 = newPotion
        newWeld.Part1 = plr.Character.RightHand
        newWeld.Parent = newPotion

        self.BasicService:PlayAnim(plr, self.AnimID)
        print("a")
        task.wait(self.PotionDisappearDelay)

        newPotion:Destroy()
        newWeld:Destroy()

        self:Drink(plr)
    end)
end

function Potion.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(Potion.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,
        
        AnimID = "rbxassetid://14862665190",
        PotionDisappearDelay = 1, -- how many seconds after pickup until effect

        BasicService = Knit.GetService("BasicService"),
        _trove = Trove.new()
    }), Potion)

    print("new potion")

    return self
end

return Potion