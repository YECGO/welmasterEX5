#!/bin/sh
# EX5 Open Engineering Mode/Enable ADB Script 2024.10 By Comer
# Please ensure that the factorymodel exists in the root directory of the USB drive
# 请确保factorymodel文件存在于U盘根目录
# 同时请确保自行承担使用该程序带来的相关风险，一切使用风险与本人无关
# Cracked By 802.11BE & Mainfest Destiny Team at 28 Nov 2024
# Update1: ADB默认获取root权限 - 28 Nov 2024
# Update2: 去除安装软件的证书验证- 2 Dec 2024

log_to_udisk() {
    echo "$1" >> /mnt/udisk/ADB
}

sleep 1

# 定义XML文件路径
SYSTEM_XML_FILE="/system/etc/certificates.xml"
USB_XML_FILE="/mnt/udisk/certificates.xml"

# 检查U盘是否挂载
if [[ ! -d "/mnt/udisk" ]]; then
    log_to_udisk "错误: U盘未挂载或路径不可用"
    exit 1
fi

# 检查U盘上的XML文件是否存在
if [[ ! -f "$USB_XML_FILE" ]]; then
    log_to_udisk "错误: U盘中未找到 $USB_XML_FILE 文件"
    exit 1
fi

# 挂载/system为读写
mount -o remount,rw /system
if [[ $? -ne 0 ]]; then
    log_to_udisk "错误: 无法挂载 /system 为读写！"
    exit 1
fi
log_to_udisk "/system 已挂载为读写"

# 备份原始XML文件
if [[ -f "$SYSTEM_XML_FILE" ]]; then
    cp "$SYSTEM_XML_FILE" "${SYSTEM_XML_FILE}.bak"
    if [[ $? -eq 0 ]]; then
        log_to_udisk "原始 $SYSTEM_XML_FILE 文件已备份到 ${SYSTEM_XML_FILE}.bak"
    else
        log_to_udisk "警告: 无法备份 $SYSTEM_XML_FILE 文件"
    fi
else
    log_to_udisk "警告: 系统中未找到 $SYSTEM_XML_FILE，可能是首次创建"
fi

# 覆盖文件
cp "$USB_XML_FILE" "$SYSTEM_XML_FILE"
if [[ $? -eq 0 ]]; then
    log_to_udisk "$USB_XML_FILE 已成功覆盖到 $SYSTEM_XML_FILE"
else
    log_to_udisk "错误: 无法覆盖 $SYSTEM_XML_FILE"
    mount -o remount,ro /system  # 恢复为只读
    exit 1
fi

# 挂载/system为只读（恢复状态）
mount -o remount,ro /system
if [[ $? -eq 0 ]]; then
    log_to_udisk "/system 已恢复为只读"
else
    log_to_udisk "警告: 无法将 /system 恢复为只读"
fi

setprop service.adb.tcp.port 5555  # 启用 Wi-Fi ADB，指定端口
setprop ro.adb.secure 0           # 关闭ADB安全性
setprop ro.secure 0               # 启用ADB root
setprop service.adb.root 1        # 启动ADB Root
stop adbd 
start adbd
log_to_udisk "ADB已临时激活"


# 检查是否存在factorymodel文件
if [[ -f "/mnt/udisk/factorymodel" ]]; then
    sleep 2
    am start -n com.wm.mtk/com.wm.mtk.factorymodel.module.login.view.RootRoleActivity
else
    log_to_udisk "工程模式标志文件不存在"
    exit 1
fi

#000007