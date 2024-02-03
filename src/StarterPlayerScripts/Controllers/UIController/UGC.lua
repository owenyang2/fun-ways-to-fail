local UGC = {}
UGC.__index = UGC

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Knit = require(RepStorage.Packages.Knit)

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

function UGC:AddUGCGoal(settings)
    local ugcFrame = RepStorage.Assets.UGCUI.UgcFrame:Clone()
    ugcFrame.Number.Text = settings.Text

    local grad = RepStorage.Assets.UGCUI.Gradients[settings.Rarity]:Clone()
    grad.Parent = ugcFrame

    ugcFrame.Parent = self.ugcUI.Frame.FrameHolder

    local updateTrove = Trove.new()
    updateTrove:Connect(RunService.Heartbeat, function()
        local inProgress = self.ProfileManager:GetData(self.Player)[settings.Stat]
        local target = settings.Goal

        ugcFrame.ClaimButton.TextLabel.Text = tostring(inProgress) .. "/" .. tostring(target)
    end)
end

function UGC:SetupUGCGoals()
    self:AddUGCGoal(
        {
            Stat = "Deaths",
            Goal = 100,
            Text = "100 Deaths",
            Rarity = "Purple"
        }
    )

    self:AddUGCGoal(
        {
            Stat = "Playtime",
            Goal = 600,
            Text = "10 Minutes of Playtime",
            Rarity = "Yellow"
        }
    )
end

function UGC:SetupUgcUI()
    self.ugcUI.Frame.Close.Activated:Connect(function()
        self.ugcUI.Visible = false
    end)

    self:SetupUGCGoals()
end

function UGC:SetupAnims()
    --self.UIFuncs.ApplyButtonClickAnim(self.ugcUI.Frame.Close)
end

function UGC:Start()
    self:SetupAnims()
    self:SetupUgcUI()
end

function UGC.new(baseTbl)
    --[[ 
    baseTbl comes with:
        UIFuncs : ModuleScript
        MainUI : ScreenGui
        Player : Player
    --]]

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        ugcUI = baseTbl.MainUI.Menus.UgcFrame,
        ProfileManager = Knit.GetService("ProfileManager"),

        _trove = Trove.new()
    }), UGC)

    return self
end

return UGC