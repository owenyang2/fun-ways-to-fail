local Shop = {}
Shop.__index = Shop

local RepStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Knit = require(RepStorage.Packages.Knit)

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

function Shop:SetupGamepassBuying(buyButton, gamepass)
    buyButton.Activated:Connect(function()
        local hasPass = false

        local succ, msg = pcall(function() -- maybe check datastore instead of api call
            hasPass = MarketplaceService:UserOwnsGamePassAsync(self.Player.UserId, gamepass.TargetId)
        end)
    
        if not succ then
            warn("Error while checking if player has pass: " .. tostring(msg))
            return
        end
    
        if not hasPass then
            MarketplaceService:PromptGamePassPurchase(self.Player, gamepass.TargetId)
        end        
    end)
end

function Shop:SetupShopUI()
    self.shopUI.Close.Activated:Connect(function()
        self.shopUI.Visible = false
    end)
    
    -- TODO: show bought on ui after bought as well as if bought before (check if bought before)
    
    self:SetupGamepassBuying(self.shopUI.HammerGamepass.BuyButton, self.ShopService:GetGamepassInfoFromName("OPHammer"))
    --self:SetupGamepassBuying(self.shopUI.SmallGamepasses.Pass1, self.ShopService:GetGamepassInfoFromName("DoubleStrength"))
    self:SetupGamepassBuying(self.shopUI.SmallGamepasses.Pass2, self.ShopService:GetGamepassInfoFromName("Sprint"))
end

function Shop:SetupAnims()
    --self.UIFuncs.ApplyButtonClickAnim(self.shopUI.Close)

    for _, button in ipairs(self.shopUI.ScrollingFrame:GetDescendants()) do
        if button:IsA("ImageButton") or button:IsA("TextButton") then
            self.UIFuncs.ApplyButtonClickAnim(button, nil, 1.05, 1.05)
        end
    end
end

function Shop:Start()
    --self:SetupAnims()
    self:SetupShopUI()
end

function Shop.new(baseTbl)
    --[[ 
    baseTbl comes with:
        UIFuncs : ModuleScript
        MainUI : ScreenGui
        Player : Player
    --]]

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        shopUI = baseTbl.MainUI.Menus.ShopFrame,
        
        ShopService = Knit.GetService("ShopService"),
        _trove = Trove.new()
    }), Shop)

    return self
end

return Shop