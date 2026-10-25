#!/bin/bash
# /input is read-only; /output is writable. No device access or flashing.
set -euo pipefail
test -r /input/build.sh
test -d /output
exec > >(tee /output/container-build.log) 2>&1
mkdir -p /work/source
# Keep every tracked path so version checks do not mistake omitted files for edits.
tar -C /input --exclude='./.git' --exclude='./.delta' -cf - . |
    tar -C /work/source -xf -
cp -a /source-git /work/git
if [ -s /work/git/objects/info/alternates ]; then
    # Delta's clone may borrow objects using a macOS-only absolute path.
    test -d /source-alternate-objects
    cp -a /source-alternate-objects/. /work/git/objects/
    rm -f /work/git/objects/info/alternates
fi
cd /work/source
export GIT_DIR=/work/git GIT_WORK_TREE=/work/source GIT_OPTIONAL_LOCKS=0
git config core.worktree /work/source
git config gc.auto 0
# Materialize current blobs from the source rather than fetching them one by one.
# All writes are to the disposable copy, never the host repository.
git add --renormalize .
timeout 60 git status --porcelain --untracked-files=no > /output/source-status.txt
git rev-parse HEAD > /output/source-commit.txt
command -v bc >/dev/null
finish() {
    local result=$?
    trap - EXIT
    cp -a bin /output/ 2>/dev/null || true
    cp -a u-boot-2016/.config u-boot-2016/u-boot \
        u-boot-2016/u-boot.strip u-boot-2016/u-boot.mbn /output/ 2>/dev/null || true
    exit "$result"
}
trap finish EXIT
uname -a
bash ./build.sh check_deps
bash ./build.sh build redmi_ax5-jdcloud
python3 - <<'PY'
import hashlib
from pathlib import Path
images = list(Path("bin").rglob("uboot-ipq60xx-redmi_ax5-jdcloud-*.bin"))
if len(images) != 1:
    raise SystemExit(f"Expected one AX5 JDCloud image, found {len(images)}")
image = images[0]
if image.stat().st_size != 655360:
    raise SystemExit(f"Unsafe image size: {image.stat().st_size}")
Path("/output/verified-image-sha256.txt").write_text(
    hashlib.sha256(image.read_bytes()).hexdigest() + "  " + str(image) + "\n"
)
PY
