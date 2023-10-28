local RepStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Knit = require(RepStorage.Packages.Knit)
local Signal = require(RepStorage.Packages.Signal)

local Ragdoll = require(script.Parent.Parent.Classes.Ragdoll)

local ToolService = Knit.CreateService {
    Name = "ToolService",
    Client = {}
}

function ToolService:CheckHoldingTool(plr : Player, tag : string)
    local holdingTool = plr.Character:FindFirstChildOfClass("Tool") -- pretty sure can only have at most 1 tool in chr, the one holding
    if not holdingTool then return false end

    if CollectionService:HasTag(holdingTool, tag) then return true end

    return false
end

function ToolService.Client:PushTarget(plr : Player, target : Player)
    print("received")
    -- check if can push
    if not plr.Character or not self.Server:CheckHoldingTool(plr, "PushTool") or not target then return end

    -- check dist
    local dist = (plr.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
    if dist > self.Server.Settings.Range then return end

    -- check cooldown
    if self.Server.LastPush[plr] then
        print(os.time() - self.Server.LastPush[plr])
    end
    if self.Server.LastPush[plr] ~= nil and os.time() - self.Server.LastPush[plr] < self.Server.Settings.Cooldown then return end
    self.Server.LastPush[plr] = os.time()

    -- ragdoll target player
    local ragdoll = Ragdoll.GlobalRagdolls[target]
    ragdoll:Toggle(true)
    ragdoll:EditCanRagdoll(false)

    task.spawn(function()
        local tempVelo = Instance.new("LinearVelocity")
        tempVelo.MaxForce = math.huge
        tempVelo.Attachment0 = target.Character.Head.FaceCenterAttachment
        tempVelo.VectorVelocity = target.Character.HumanoidRootPart.CFrame.LookVector.Unit * self.Server.Settings.FallForce
        tempVelo.Name = "PushForce"
        tempVelo.Parent = target.Character.HumanoidRootPart

        task.wait(0.2)

        tempVelo:Destroy()
    end)

    task.wait(self.Server.Settings.RagdollTime)

    ragdoll:EditCanRagdoll(true)
    ragdoll:Toggle(false)
end

function ToolService:KnitStart()
    self.RagdollService = Knit.GetService("RagdollService")

    self.Settings = {
        Cooldown = 3,
        Range = 5,
        RagdollTime = 3,
        FallForce = 15,
    }

    self.LastPush = {} -- keeps track of each player's last push
end

return ToolService