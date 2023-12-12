#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

# Disable debugfs for user builds
export MAKE_ARGS=$@

# Check conditions for user build and arm64 architecture
if [ "$DISABLE_DEBUGFS" == "true" ] && [ "$TARGET_BUILD_VARIANT" == "user" ] && [ "$ARCH" == "arm64" ]; then
    echo "Build variant: $TARGET_BUILD_VARIANT"
    echo "Combining fragments for user build"

    # Combine config fragments
    (
        cd "$KERNEL_DIR" &&
        ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" \
        ./scripts/kconfig/merge_config.sh \
            ./arch/"$ARCH"/configs/"$DEFCONFIG" \
            ./arch/"$ARCH"/configs/vendor/debugfs.config

        # Save and update defconfig
        make "$MAKE_ARGS" ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" savedefconfig
        mv defconfig ./arch/"$ARCH"/configs/"$DEFCONFIG"
        rm .config
    )
elif [ "$DISABLE_DEBUGFS" == "true" ] && [[ "$DEFCONFIG" == *"perf_defconfig"* ]] && [ "$ARCH" == "arm64" ]; then
    echo "Build variant: $TARGET_BUILD_VARIANT"
    echo "Resetting perf defconfig"

    # Reset perf defconfig
    (
        cd "$KERNEL_DIR" &&
        git checkout "arch/$ARCH/configs/$DEFCONFIG"
    )
fi
