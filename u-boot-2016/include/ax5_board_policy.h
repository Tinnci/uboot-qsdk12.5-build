/* SPDX-License-Identifier: GPL-2.0+ */
#ifndef AX5_BOARD_POLICY_H
#define AX5_BOARD_POLICY_H
#include <net.h>
/* Runtime SMEM guard as well as an exact board build guard. */
static inline int ax5_skip_optional_flash(int boot_is_emmc)
{
#ifdef CONFIG_TARGET_IPQ6018_REDMI_AX5_JDCLOUD
 return boot_is_emmc;
#else
 (void)boot_is_emmc;
 return 0;
#endif
}
/* Preserve ART and secondary MACs; net core already prefers this environment MAC. */
static inline int ax5_complete_primary_mac(unsigned char *mac, unsigned count)
{
#ifdef CONFIG_TARGET_IPQ6018_REDMI_AX5_JDCLOUD
 if (count && !is_valid_ethaddr(mac) && eth_getenv_enetaddr("ethaddr", mac))
  return 1;
#else
 (void)mac; (void)count;
#endif
 return 0;
}
#endif
