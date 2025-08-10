local aghanimDropper = {}

aghanimDropper.menu = {}
aghanimDropper.menu.main = Menu.Create("Heroes", "Hero List", "Treant Protector")
aghanimDropper.menu.generalTab = aghanimDropper.menu.main:Create("Main Settings")
aghanimDropper.menu.generalSettingsGroup = aghanimDropper.menu.generalTab:Create("Settings", Enum.GroupSide.FullWidth)
aghanimDropper.menu.generalEnabled = aghanimDropper.menu.generalSettingsGroup:Switch("Enabled", false, "\u{f00c}")
aghanimDropper.menu.generalDropKey = aghanimDropper.menu.generalSettingsGroup:Bind("Drop Key", Enum.ButtonCode.KEY_NONE, "\u{f11c}")
aghanimDropper.menu.generalPickUpDelay = aghanimDropper.menu.generalSettingsGroup:Slider("Pickup Delay", 0.01, 2, 0.0005, function (value) return string.format("%.2f", value) end)

function aghanimDropper:init()
    self.myHero = Heroes.GetLocal()
    self.myPlayer = Players.GetLocal()
    self.dropTime = nil
end

function aghanimDropper:update()
    if not self.menu.generalEnabled:Get() then return end

    if self.myHero == nil or self.myPlayer == nil then
        self:init()
        return
    end

    if aghanimDropper.menu.generalDropKey:IsDown() then
        local aghanim = NPC.GetItem(self.myHero, "item_ultimate_scepter")
        if aghanim and Item.IsDroppable(aghanim) then
            Player.PrepareUnitOrders(
                self.myPlayer,
                Enum.UnitOrder.DOTA_UNIT_ORDER_DROP_ITEM,
                nil,
                Entity.GetAbsOrigin(self.myHero),
                aghanim,
                Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY,
                self.myHero,
                false,
                false,
                true
            )
            self.dropTime = GameRules.GetGameTime()
        end
    end

    if self.dropTime then
        if GameRules.GetGameTime() - self.dropTime >= self.menu.generalPickUpDelay:Get() then
            for _, physItem in pairs(PhysicalItems.GetAll()) do
                local item = PhysicalItem.GetItem(physItem)
                if item and Ability.GetName(item) == "item_ultimate_scepter" then
                    local itemPos = Entity.GetAbsOrigin(physItem)
                    local myHeroPos = Entity.GetAbsOrigin(self.myHero)
                    if (itemPos and myHeroPos and (itemPos - myHeroPos):Length2D() < 200) then
                        Player.PrepareUnitOrders(self.myPlayer, Enum.UnitOrder.DOTA_UNIT_ORDER_PICKUP_ITEM, physItem, Vector(0, 0, 0), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, self.myHero, false, false, true)
                        self.dropTime = nil
                    end
                end
            end
        end

        if self.dropTime and GameRules.GetGameTime() - self.dropTime > 0.8 then
            self.dropTime = nil
        end
    end
end

return {
    OnUpdate = function()
        aghanimDropper:update()
    end
}
