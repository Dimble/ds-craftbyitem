-- don't load a game you care about with these enabled
GLOBAL.CHEATS_ENABLED = true
GLOBAL.require("debugkeys")
GLOBAL.tst = {}

--[[
    Tired of scrolling through all of the crafting tabs just to find that one recipe for the red feather you just picked up?  Have we got a mod for you!  This sticks a tab left of your inventory that shows the last item selected.  Clicking the tab brings up a crafting bar of only the recipes that work with that item.

Note that the bar is of limited usefulness for frequently-used items such as twigs or grass.
--]]

--[[
    TODO
    - looks like something stops OnUpdate when the bar is hidden or disabled
        - move the update_needed stuff to Tab OnUpdate somehow
    - need to update after crafting (game crafting bars close..)
    - maybe if the selected item is a recipe product, add that to the list
    - maybe clear the tab if the selected item is no longer in the inventory?
    - maybe clear the tab after n time?
--]]

local require = GLOBAL.require

Assets = {
         Asset("ATLAS", "images/popup-down.xml")
         }

local ItemTab = require "itemtab"
local ItemCraft = require "itemcraft"
local tab
local craft

local function NewActiveItem(_, data)
    tab:NewActiveItem(data)
end

local function ReUpdate(_, data)
    craft:UpdateRecipes()
end

env.AddSimPostInit(function(player)
    local c = GLOBAL.GetPlayer().HUD.controls


    tab = c:AddChild(ItemTab())
GLOBAL.tst.tab = tab

    craft = ItemCraft()
    craft:Hide()
GLOBAL.tst.craft = craft

    tab.crafting = craft
    craft.itemtab = tab

    local deferupdate = GetModConfigData("defer update")
    craft.deferupdate = deferupdate

    tab:AttachInventory()
    tab.inst:ListenForEvent("newactiveitem", NewActiveItem, player)
    tab.inst:ListenForEvent("techtreechange", ReUpdate, player)
    tab.inst:ListenForEvent("itemget", ReUpdate, player)
    tab.inst:ListenForEvent("itemlose", ReUpdate, player)
    tab.inst:ListenForEvent("stacksizechange", ReUpdate, player)
    tab.inst:ListenForEvent("unlockrecipe", ReUpdate, player)
end)

-- If desired, uncomment and set to your preferred key..
-- though I can't figure out how to get the labels from constants.lua
--[ [
    GLOBAL.TheInput:AddKeyDownHandler(105, function()
--    GLOBAL.TheInput:AddKeyDownHandler(KEY_I, function()
        if ( craft.open ) then
            craft:Close()
        else
            craft:Open()
        end
    end)
--] ]

--[[
TODO

FIXME
    - unknown unknowns
--]]

-- vim: ts=4:sw=4:et
