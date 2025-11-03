---Ext.Require files at the path
---@param path string
---@param files string[]
function RequireFiles(path, files)
    for _, file in pairs(files) do
        _P(string.format("   [Dawnforged] Requiring file: %s%s.lua", path, file))
        Ext.Require(string.format("%s%s.lua", path, file))
    end
end

RequireFiles("shared/", {
    "MetaClass",
    "PixieLib"
})

function LevelGamePlayReady(_LevelName, _IsEditorMode)
    _P(string.format("   [Dawnforged] LevelGamePlayReady called for level '%s'.", tostring(_LevelName)))

    -- Only run on the Nautiloid tutorial map
    if not _LevelName or not _LevelName:find("TUT_Avernus_C") then
        _P(string.format("   [Dawnforged] Skipping item injection; current level is '%s'", tostring(_LevelName)))
        return
    end

    _P("   [Dawnforged] LevelGamePlayReady triggered...Initializing...")

    local chest = "a0a59732-eb0c-489c-a8cb-488ab858de28" -- GustavDev/TUT_Avernus_C/Items/S_Chest_Secret_Grenades

    local DawnforgedItems = {
        ShadowsHeart = "2f5636ff-8f50-47cd-9e3e-267ee39e806b",
        Argentum = "4afeda45-5957-410c-b13c-e37e0824d7ed",
        Tonitrum = "b9a39f76-73a8-4d6d-8f83-d93d3e0d015c",
        Patentibus = "1638043b-c566-41ac-8d36-a2aaedb7e32c",
        Tonitrolus = "d63151b1-4cc1-45d6-948e-60b3b620058a",
        Malevolence = "2d0a3da2-d188-425e-9a55-77e2035f713b",
        Malice = "8dd8e38c-43fe-4b18-a41e-b806e78c3f62",
        Jubar = "ca6f5186-f56b-492e-8720-fbcab7a38b2c",
        Moonshadow = "1186205f-5247-4015-824b-87b6ccf3aeb7",
        WarpBinder = "91d269b6-6b9d-4c24-a107-50e7765c1117",
        GravebindersMantle = "a997b51b-2f68-47da-9970-ef7eca06e4e2",
        Furybound = "c221a696-d25e-47b7-816e-36889eed00a6",
        Moonfinger = "7a72adc8-e6e7-46d5-b8b8-be2f2ce9b51d",
        Lockbane = "fa962a4f-2c7a-4d47-8b2c-1878e84a9236",
        Dawnstrider = "65fe45e8-2144-42f8-a181-0cce9c28a779",
        MorninglordsMantle = "f3f9b424-a19d-4846-a06c-a35ac2b4f353",
        RingSilverThreshold = "9c8268ba-f57e-423d-a0cd-0576254dc691",
        DawnforgedHammer = "315500b0-02d4-4827-a021-bc418e97ffc1",
        Sunpiercer = "211bc74f-29d8-4d29-89fe-21ac1d5b8ee6"
    }

    for name, uuid in pairs(DawnforgedItems) do
        local ok, err = pcall(function()
            PixieLib:AddItemToContainer(uuid, chest)
            _P(string.format("   [Dawnforged] Inserted %s (%s) into chest.", name, uuid))
        end)
        if not ok then
            _P(string.format("   [Dawnforged] Failed to insert %s: %s", name, err))
        end
    end
end

Ext.Events.SessionLoaded:Subscribe(function()
    _P("   [Dawnforged] Session loaded, registering LevelGamePlayReady listener.")
    Ext.Osiris.RegisterListener("LevelGamePlayReady", 2, "after", LevelGamePlayReady)
end)

_P("   [Dawnforged] _Init.lua loaded successfully.")
