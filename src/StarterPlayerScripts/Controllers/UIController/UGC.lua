local UGC = {}
UGC.__index = UGC

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

function UGC:SetupUgcUI()
    self.ugcUI.Frame.Close.Activated:Connect(function()
        self.ugcUI.Visible = false
    end)
end

function UGC:SetupAnims()
    self.UIFuncs.ApplyButtonClickAnim(self.ugcUI.Frame.Close)

    for _, button in ipairs(self.ugcUI.Frame.FrameHolder:GetDescendants()) do
        if button:IsA("ImageButton") or button:IsA("TextButton") then
            self.UIFuncs.ApplyButtonClickAnim(button, nil, 1.05, 1.05)
        end
    end
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

        _trove = Trove.new()
    }), UGC)

    return self
end

return UGC