local MODULE = "VAS-SCU"
local CALLBACK_ID = "vas_subordinates_config_unlocker"

local ffi = require("ffi")
local C = ffi.C

ffi.cdef[[
    typedef uint64_t UniverseID;
    UniverseID GetPlayerID(void);
]]

local mapMenu = nil
local registered = false
local cachedPlayerID = nil

local DISTANCE_PARAMS = {
    minbuy = true,
    maxbuy = true,
    minsell = true,
    maxsell = true,
}

local TRADE_ORDERS = {
    TradeRoutine = true,
    TradeRoutine_Basic = true,
    TradeRoutine_Advanced = true,
}

local MINING_ORDERS = {
    MiningRoutine = true,
    MiningRoutine_Basic = true,
    MiningRoutine_Advanced = true,
    MiningRoutine_Expert = true,
}

local function playerID()
    if not cachedPlayerID then
        local rawPlayerID = C.GetPlayerID()
        if rawPlayerID == 0 then
            return nil
        end
        cachedPlayerID = ConvertStringTo64Bit(tostring(rawPlayerID))
        if cachedPlayerID == 0 then
            cachedPlayerID = nil
            return nil
        end
    end
    return cachedPlayerID
end

local function configFlag(name, default)
    local id = playerID()
    if not id then return default end
    local value = GetNPCBlackboard(id, name)
    if value == nil then return default end
    return value == true or value == 1
end

local function isDebugEnabled()
    local id = playerID()
    if not id then return false end
    local chance = GetNPCBlackboard(id, "$vas_scu_debug_chance")
    return type(chance) == "number" and chance > 0
end

local function debug(message)
    if isDebugEnabled() then
        DebugError("[" .. MODULE .. "] " .. tostring(message))
    end
end

local function getOrderDefID(order)
    if not order then return nil end
    if order.orderdefref and order.orderdefref.id then
        return order.orderdefref.id
    end
    return order.orderdef or order.id
end

local function getParamName(order, paramidx, param)
    if param and param.name then
        return param.name
    end
    if order and order.params and paramidx and order.params[paramidx] then
        return order.params[paramidx].name
    end
    return nil
end

local function getSelectedAssignment(instance)
    if not mapMenu or not mapMenu.infoTableData or not mapMenu.infoTableData[instance] then
        return nil
    end
    local component = mapMenu.infoSubmenuObject
    if not component then
        return nil
    end
    local ok, assignment = pcall(GetComponentData, component, "assignment")
    if ok then
        return assignment
    end
    return nil
end

local function isEnabledForAssignment(assignment)
    if assignment == "trade" then
        return configFlag("$vas_scu_unlock_traders", true)
    elseif assignment == "tradeforbuildstorage" then
        return configFlag("$vas_scu_unlock_build_storage_traders", true)
    elseif assignment == "mining" then
        return configFlag("$vas_scu_unlock_miners", true)
    end
    return false
end

local function isUnlockableDistanceParam(orderidx, order, paramidx, param, instance)
    if orderidx ~= "default" then
        return false
    end
    if not mapMenu or not mapMenu.infoTableData or not mapMenu.infoTableData[instance] then
        return false
    end

    local infoTableData = mapMenu.infoTableData[instance]
    if not infoTableData.commander then
        return false
    end

    local paramName = getParamName(order, paramidx, param)
    if not DISTANCE_PARAMS[paramName] then
        return false
    end

    local assignment = getSelectedAssignment(instance)
    if not isEnabledForAssignment(assignment) then
        return false
    end

    local orderID = getOrderDefID(order) or getOrderDefID(infoTableData.defaultorder)
    if assignment == "mining" then
        return MINING_ORDERS[orderID] == true
    end
    return TRADE_ORDERS[orderID] == true
end

local function changeParamActive(ftable, orderidx, order, paramidx, param, listidx, instance, paramactive)
    if paramactive then
        return nil
    end

    if isUnlockableDistanceParam(orderidx, order, paramidx, param, instance) then
        debug(string.format("Unlocked default distance param %s for %s.", tostring(getParamName(order, paramidx, param)), tostring(getSelectedAssignment(instance))))
        return { paramactive = true }
    end

    return nil
end

local function init()
    if registered then
        return
    end
    if not Helper or type(Helper.getMenu) ~= "function" then
        debug("Helper.getMenu is unavailable; UIX callback not registered.")
        return
    end

    mapMenu = Helper.getMenu("MapMenu")
    if not mapMenu or type(mapMenu.registerCallback) ~= "function" then
        debug("MapMenu/UIX callback API is unavailable; UIX callback not registered.")
        return
    end

    mapMenu.registerCallback("displayOrderParam_change_paramactive", changeParamActive, CALLBACK_ID)
    registered = true
    debug("Registered UIX callback for subordinate default-order distance editing.")
end

if type(Register_OnLoad_Init) == "function" then
    Register_OnLoad_Init(init, "extensions.vas_subordinates_config_unlocker.ui.subordinates_config_unlocker")
end

init()
