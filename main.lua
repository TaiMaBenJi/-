--[[
唯一的游戏策略控制器V1. 2.8 
API_VERSION=4
由TencentXLab@2024验证
作者QQ:2251149780
优化说明：
1. 唯一性保障：
- 添加唯一标识符 `_UNIQUE_ID`
- 所有函数添加唯一前缀 `XGAME_`
- 加入版权标识和版本信息

2. 增强健壮性：
- 添加API版本校验
- 使用pcall进行错误捕获
- 增加详细日志记录(logi/loge/logw)

3. 结构优化：
- 使用配置表管理策略
- 分离策略应用逻辑
- 支持动态策略扩展

4. 兼容性改进：
- 保留原有功能逻辑
- 支持多集群配置
- 同时兼容绝对/相对策略

使用时请确保：
1. 保持API_VERSION = 4
2. 调用对应接口：
   - XGAME_load_policy()
   - XGAME_fps_adjust()
   - XGAME_cleanup()
3. 日志系统需要支持logi/loge/logw函数
]]

local _UNIQUE_ID = "XGAME_POLICY_CTL_6A2F9D"

-- 配置表优化
local _GAME_PROFILES = {
    MOBA = {
        packages = {
            "com.tencent.tmgp.sgame",          -- 王者荣耀
            "com.levelinfinite.sgameGlobal",   -- 国际版王者
            "com.netease.moba"                 -- 决战平安京
        },
        policies = {
            { type = "abs", cluster = 7, freq_min = 1130000, freq_max = 1555000 }
        }
    },
    
    DNF = {
        packages = { "com.tencent.tmgp.dnf" },
        policies = {
            { type = "rel", cluster = 0, base = 7, offset_min = 50000, offset_max = 400000 },
            { type = "rel", cluster = 4, base = 7, offset_min = 50000, offset_max = 400000 }
        }
    },
    
    LOL_MOBILE = {
        packages = { "com.tencent.lolm" },
        policies = {
            { type = "rel", cluster = 4, base = 7, offset_min = 0, offset_max = -900000 }
        }
    }
    -- 其他游戏配置...QQ:2251149780
}

local function _XGAME_apply_policy(policy)
    if policy.type == "abs" then
        set_extra_policy_abs(policy.cluster, policy.freq_min, policy.freq_max)
    elseif policy.type == "rel" then
        set_extra_policy_rel(policy.cluster, policy.base, policy.offset_min, policy.offset_max)
    end
end

function XGAME_load_policy(pid, pkg)
    if API_VERSION ~= 4 then
        logw(_UNIQUE_ID..": Unsupported API version!")
        return
    end

    -- 配置匹配
    for _, profile in pairs(_GAME_PROFILES) do
        for _, pkg_pattern in ipairs(profile.packages) do
            if pkg == pkg_pattern then
                logi(_UNIQUE_ID..": Applying profile for "..pkg)
                for _, policy in ipairs(profile.policies) do
                    pcall(_XGAME_apply_policy, policy)
                end
                return
            end
        end
    end

    -- 动态策略扩展
    if pkg == "com.tencent.KiHan" then    -- 火影忍者
        pcall(set_extra_policy_abs, 7, 1130000, 1766000)
    elseif pkg == "com.tencent.tmgp.pubgmhd" then  -- 和平精英
        pcall(set_extra_policy_abs, 4, 921000, 1651000)
    end
end

function XGAME_fps_adjust(target_fps, pkg)
    local success, err = pcall(function()
        if pkg == "com.tencent.KiHan" then
            if target_fps <= 94 then
                set_extra_policy_abs(7, 1130000, 1766000)
            elseif target_fps <= 122 then
                set_extra_policy_abs(7, 1130000, 2112000)
            end
        elseif pkg == "com.tencent.tmgp.pubgmhd" then
            if target_fps <= 94 then
                set_extra_policy_abs(4, 921000, 1651000)
            elseif target_fps <= 122 then
                set_extra_policy_abs(4, 921000, 1996000)
            end
        end
    end)
    
    if not success then
        loge(_UNIQUE_ID..": FPS adjust failed: "..tostring(err))
    end
end

function XGAME_cleanup()
    remove_extra_policy(4)
    remove_extra_policy(7)
    logi(_UNIQUE_ID..": Policies cleaned up")
end

-- 版本校验
if API_VERSION == 4 then
    logi(_UNIQUE_ID..": Controller initialized (API v4)")
else
    logw(_UNIQUE_ID..": Version mismatch! Expected API v4")
end
