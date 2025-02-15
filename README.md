先刷入fas-rs，才可以刷唯一的游戏策略控制器。
有问题反馈作者QQ:2251149780
{
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
}
