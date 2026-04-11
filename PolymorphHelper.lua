-- Polymorph Helper addon
-- Shows which Polymorph variants your Mage has learned and how to get missing ones.

local PolymorphHelper = CreateFrame("Frame", "PolymorphHelperFrame")

-- Helper: build a chat-clickable item link for tooltip-on-hover
local function itemLink(itemID, label)
    return ("|cff0070dd|Hitem:%d:::::::::::::|h[%s]|h|r"):format(itemID, label)
end

-- Polymorph variant entries.
-- spellID:     checked via C_SpellBook.IsSpellKnownOrInSpellBook()
-- itemID:      used to generate a hoverable tooltip link (0 = no item)
-- itemName:    display name inside the item link
-- seasonal:    true if only available during a limited-time event
-- seasonName:  name of the event shown in the hint
-- faction:     "Alliance", "Horde", or nil for both
-- hint:        plain-text fallback when no itemID, or extra context
local variants = {
    {
        name      = "Pig",
        spellID   = 28272,
        itemID    = 0,
        itemName  = "",
        hint      = "Trained by The Amazing Zanzo in Dalaran (wanders around — check near the bank!)",
    },
    {
        name      = "Black Cat",
        spellID   = 61305,
        itemID    = 44709,
        itemName  = "Tome of Polymorph: Black Cat",
        hint      = "Sold by Endora Moorehead in Northrend Dalaran (limited stock — check back if sold out)",
    },
    {
        name      = "Turtle",
        spellID   = 28271,
        itemID    = 22739,
        itemName  = "Tome of Polymorph: Turtle",
        hint      = "Fished from pools in Cataclysm zones, or check the Auction House",
    },
    {
        name       = "Rabbit",
        spellID    = 61721,
        itemID     = 44793,
        itemName   = "Tome of Polymorph: Rabbit",
        seasonal   = true,
        seasonName = "Noblegarden",
        hint       = "100 Noblegarden Chocolates from event vendors (Noblegarden only, Bind on Pickup!)",
    },
    {
        name      = "Polar Bear Cub",
        spellID   = 161353,
        itemID    = 120137,
        itemName  = "Tome of Polymorph: Polar Bear Cub",
        hint      = "Rare drop (~0.5%) from Arctic Grizzlies in Dragonblight, or check the Auction House",
    },
    {
        name      = "Porcupine",
        spellID   = 126819,
        itemID    = 120140,
        itemName  = "Tome of Polymorph: Porcupine",
        hint      = "Drops from porcupines in Pandaria, or check the Auction House",
    },
    {
        name      = "Monkey",
        spellID   = 161354,
        itemID    = 120138,
        itemName  = "Tome of Polymorph: Monkey",
        hint      = "Drops from Hozen in Pandaria, or check the Auction House",
    },
    {
        name      = "Direhorn",
        spellID   = 277787,
        itemID    = 162625,
        itemName  = "Tome of Polymorph: Direhorn",
        faction   = "Horde",
        hint      = "Sold by Natal'hakata in Dazar'alor (Zandalari Empire, Revered)",
    },
    {
        name      = "Bumblebee",
        spellID   = 277792,
        itemID    = 162626,
        itemName  = "Tome of Polymorph: Bumblebee",
        faction   = "Alliance",
        hint      = "Sold by Sister Lilyana in Stormsong Valley (Storm's Wake, Revered)",
    },
    {
        name      = "Duck",
        spellID   = 391622,
        itemID    = 200205,
        itemName  = "Tome of Polymorph: Duck",
        hint      = "Hidden cave in Azure Span (66, 32) — Blink through the rocks, complete quest 'Best Spell Ever'",
    },
    {
        name      = "Mosswool",
        spellID   = 460392,
        itemID    = 227710,
        itemName  = "Tome of Polymorph: Mosswool",
        hint      = "Hidden area in Dornogal — The Corridors (NE of city), complete quest 'Easy Win'",
    },
}

local GREEN  = "|cFF00FF00"
local RED    = "|cFFFF0000"
local GREY   = "|cFF999999"
local GOLD   = "|cFFFFD100"
local ORANGE = "|cFFFF8000"
local TAG    = GREEN .. "PolymorphHelper:|r "

local function colorYesNo(ok)
    return ok and (GREEN .. "Yes|r") or (RED .. "No|r")
end

function PolymorphHelper:Print(msg)
    print(TAG .. msg)
end

function PolymorphHelper:GetPlayerFaction()
    return UnitFactionGroup("player")
end

function PolymorphHelper:DisplayVariants()
    local _, classToken = UnitClass("player")
    if classToken ~= "MAGE" then
        self:Print("You are not a Mage.")
        return
    end

    local playerFaction = self:GetPlayerFaction()

    self:Print("Polymorph variants (Sheep is always known):")

    for _, v in ipairs(variants) do
        local known = C_SpellBook.IsSpellKnownOrInSpellBook(v.spellID)

        local line = ("- %s: %s"):format(v.name, colorYesNo(known))

        if known then
            if v.seasonal then
                line = line .. "  " .. GREY .. "(" .. v.seasonName .. " seasonal)|r"
            end
        else
            if v.faction and v.faction ~= playerFaction then
                line = line .. "  " .. GREY .. "(" .. v.faction .. " only)|r"
            else
                if v.itemID and v.itemID ~= 0 then
                    line = line .. "  " .. itemLink(v.itemID, v.itemName)
                    if v.seasonal then
                        line = line .. "  " .. ORANGE .. "(" .. v.seasonName .. " only — limited time!)|r"
                    end
                else
                    line = line .. "  " .. GOLD .. v.hint .. "|r"
                end
            end
        end

        self:Print(line)
    end

    self:Print(GREY .. "\nTip: Hover blue item links to see the tome tooltip. Most tomes can also be found on the Auction House!|r")
end

PolymorphHelper:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        self:Print("Loaded. Type /polyhelp to check your Polymorph variants.")
    end
end)
PolymorphHelper:RegisterEvent("PLAYER_LOGIN")

SLASH_POLYMORPHHELPER1 = "/polyhelp"
SlashCmdList["POLYMORPHHELPER"] = function()
    PolymorphHelper:DisplayVariants()
end
