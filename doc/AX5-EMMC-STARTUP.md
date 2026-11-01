# AX5 京东云 eMMC 启动策略

本改动仅在 CONFIG_TARGET_IPQ6018_REDMI_AX5_JDCLOUD 编译目标下生效。

- SMEM 确认从 eMMC 启动时，board_nand_init 不探测板上不存在的 NAND/SPI。
- Web 介质能力检测同样跳过该板的 SPI 探测，保留真实 MMC 容量检测。
- ART 第一项 MAC 无效而已有 ethaddr 有效时，只在读取缓冲区补入原环境 MAC。
  不修改 ART、不生成随机地址，也不替换其余有效 MAC。
  此前 net core 已实际采用该环境地址，因此不改变现有线上的 primary MAC。
- 非 AX5 板型、非 eMMC 启动仍保持原路径。ART 与环境都无效时保持原失败/回退路径。
- 不改变 GPT、环境布局、FIT 加载、MMC 时序、DDR、救援网络或固件刷写接口。

`sh tests/test-ax5-policy.sh` 用真实策略头分别编译 AX5 / 其他板型测试，覆盖
非eMMC、有效ART、无效ART/有效环境、无效环境、零MAC数量、保留后续MAC条目。
完整目标编译及实验机串口启动验证仍然必需；单元测试不能证明硬件时序或恢复入口。
