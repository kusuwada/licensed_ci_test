#!/bin/bash
set -vxeu

################################################################################
#
# 説明
# ==========
#
# CI環境でlicenseチェックを実行するための設定をし、licensedを実行します。
#
#
# パラメータ
# ==========
#
# 1. ベースディレクトリパス
#    プロジェクトのベースディレクトリパス
#    e.g.) /codebuild/output/srcxxxxxxxx/src/github.com/kusuwada/licensed_ci_test
#
# 2. licenseチェック実行ログ・成果物格納先へのパス
#    e.g.) /tmp/log
#
################################################################################

: $1 $2

BASE_DIR="${1}"
RESULT_DIR="${2}"

PYVENV_DIR=${BASE_DIR}/license_check
LICENSED_DIR=${PYVENV_DIR}/app/.licensed
LIBRARY_CACHE_DIR=${LICENSED_DIR}/.licenses

echo ${BASE_DIR}
echo ${RESULT_DIR}

mkdir ${PYVENV_DIR}
virtualenv ${PYVENV_DIR} --no-site-packages
cd ${PYVENV_DIR}
chmod 755 bin/activate
set -eu
. bin/activate
set +eu
cp -R ${BASE_DIR}/app .
cd app
pip install -r ./backend/requirements.txt
pip install -r ./front/requirements.txt
mkdir ${LICENSED_DIR}
cd ${LICENSED_DIR}
pip freeze -l > requirements.txt

bundle init
echo "gem 'licensed', :group => 'development'" >> Gemfile
bundle install --path vendor/bundle
cp ${BASE_DIR}/tool/ci_cd/.licensed.yml .
sed -ie "s|__SOURCE_PATH__|${LICENSED_DIR}|" .licensed.yml
sed -ie "s|__CACHE_PATH__|${LIBRARY_CACHE_DIR}|" .licensed.yml
sed -ie "s|__VIRTUAL_ENV_DIR__|${PYVENV_DIR}|" .licensed.yml
cat .licensed.yml

bundle exec licensed cache
bundle exec licensed status > ${RESULT_DIR}/licensed_status.log
cp ${BASE_DIR}/tool/ci_cd/licensed2csv.py ${LIBRARY_CACHE_DIR}
cd ${LIBRARY_CACHE_DIR}
python licensed2csv.py
cp libraries.csv ${RESULT_DIR}
