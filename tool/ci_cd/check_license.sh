#!/bin/bash
set -vxeu

################################################################################
#
# 説明
# ==========
#
# 引数で渡された licensed のstatusログファイルに記載された結果にwarningがあるかどうかを判断する。
#  - 01.licensed のログファイルにある結果の部分を取得
#  - 02.warningが0件でない場合は異常終了
#
#
# パラメータ
# ==========
#
# 1. licensed のログファイルパス
#    e.g.) /tmp/log/licensed_status.log
#
#
################################################################################

: $1

RESULT_FILE="${1}"

WARNING=`grep "warnings found" ${RESULT_FILE} | sed -e 's/.*dependencies checked, //g' | sed 's/warnings found.//g'`

echo "warning count: ${WARNING}"

CHECK=`echo "${WARNING} == 0" | bc`

if [ ${CHECK} -eq 0 ];
then
    echo "license NG : ${WARNING}" 
    exit 1
fi

exit 0
