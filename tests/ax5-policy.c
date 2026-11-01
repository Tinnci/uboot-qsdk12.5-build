#include <assert.h>
#include <string.h>
#include <ax5_board_policy.h>
static unsigned env_reads;
static int env_valid;
static const unsigned char saved[6] = {0x6a, 0x84, 0xee, 0x52, 0xd5, 0x29};
int is_valid_ethaddr(const unsigned char *mac)
{
 static const unsigned char zero[6];
 return !(mac[0] & 1) && memcmp(mac, zero, 6);
}
int eth_getenv_enetaddr(const char *name, unsigned char *mac)
{
 assert(!strcmp(name, "ethaddr")); env_reads++;
 if (!env_valid) return 0;
 memcpy(mac, saved, 6); return 1;
}
int main(void)
{
 unsigned char art[36], before[36];
 memset(art, 0xa4, sizeof art); memset(art, 0, 6); memcpy(before, art, sizeof art);
 assert(!ax5_skip_optional_flash(0));
 assert(!ax5_complete_primary_mac(NULL, 0));
 env_valid = 1;
#ifdef CONFIG_TARGET_IPQ6018_REDMI_AX5_JDCLOUD
 assert(ax5_skip_optional_flash(1));
 assert(ax5_complete_primary_mac(art, 6));
 assert(!memcmp(art, saved, 6));
 assert(!memcmp(art + 6, before + 6, 30));
 unsigned calls = env_reads;
 assert(!ax5_complete_primary_mac(art, 6));
 assert(calls == env_reads); /* Valid ART MAC is never replaced. */
 env_valid = 0; memset(art, 0, 6); memcpy(before, art, sizeof art);
 assert(!ax5_complete_primary_mac(art, 6));
 assert(!memcmp(art, before, sizeof art));
#else
 assert(!ax5_skip_optional_flash(1));
 assert(!ax5_complete_primary_mac(art, 6));
 assert(!memcmp(art, before, sizeof art));
 assert(!env_reads);
#endif
 return 0;
}
