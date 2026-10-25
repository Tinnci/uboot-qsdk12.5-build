# Apple container: AX5 JDCloud U-Boot

Bundled GCC is an x86-64 glibc Linux executable producing ARM code.
Use amd64 Ubuntu with Rosetta, not Alpine. Build from this small context:

```sh
container build --arch amd64 -t ax5-uboot:ubuntu24 -f container/Containerfile container
```

Run from the repository root with a fresh output directory:

```sh
output="$(git rev-parse --absolute-git-dir)/container-output/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$output"
# For a Delta clone with a single alternate object store:
alternate="$(cat "$(git rev-parse --absolute-git-dir)/objects/info/alternates")"
container run --rm --arch amd64 --rosetta --cpus 4 --memory 4G \
  --mount "type=bind,source=$PWD,target=/input,readonly" \
  --mount "type=bind,source=$(git rev-parse --absolute-git-dir),target=/source-git,readonly" \
  --mount "type=bind,source=$alternate,target=/source-alternate-objects,readonly" \
  --mount "type=bind,source=$output,target=/output" \
  ax5-uboot:ubuntu24 bash /input/container/build-ax5.sh
```

Source is read-only, compilation uses the disposable Linux filesystem,
and artifacts/configuration/logs are copied out. No device, credentials
or SSH agent is forwarded, and nothing is flashed. The VM needs room for
the toolchain and build tree. Existing source edits are included.

For a normal clone without `objects/info/alternates`, omit the `alternate`
assignment and its mount. Multiple/nested alternates need materialization
before using this recipe. Git metadata and alternate objects are copied into
the container's writable filesystem, preserving the original commit identity.

Ubuntu's tag and apt repositories can change; record resolved image digest
and source commit for releases. npm versions are pinned. This is not yet a
bit-for-bit reproducible environment. A 640 KiB check is not boot validation.
