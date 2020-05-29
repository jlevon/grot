#!/bin/bash

#
# MANATEE-381
#
# Report if we find an ISM segment such that if we were to restart the postgres
# instance, it might not be able to allocate it again.
#
# Needs to run on the global zone as root/pfexec. Should be harmless to run this if no
# arguments are provided.
#
# If invoked as "./manatee-381.sh apply-workaround" we will try to scale
# segspt_minfree down in the hope that the subsequent shmat() works.
#

set -e

mem_pages=$(( $(sysinfo -p | grep MiB_of_Memory | cut -d= -f2) * 256 ))
availrmem_pages=$(echo $(echo availrmem/D  | mdb -k | cut -d: -f2))
largest_ism_pages=$(( $(ipcs -bimZ | awk 'BEGIN { a = 0 } NR > 3 && $8 > 0 { if ($7 > 0 + a) a = $7 } END { print a }') / 4096 ))
segspt_minfree_pages=$(mdb -ke segspt_minfree/D | tail -1 | awk '{print $2}')
ani_mem_resv_pages=$(mdb -ke "k_anoninfo::print ani_mem_resv | =E")
ani_locked_swap_pages=$(mdb -ke "k_anoninfo::print ani_locked_swap | =E")

print_pages()
{
	echo "$1: $2 ( $(( $2 / 256 )) Mb )"
}

echo "Host UUID: $(sysinfo -p | grep UUID)"
print_pages "Total memory pages" $mem_pages
print_pages "availrmem pages" $availrmem_pages
print_pages "largest_ism_pages" $largest_ism_pages
print_pages "segspt_minfree_pages" $segspt_minfree_pages
mdb -ke "k_anoninfo::print"

#
# Although we can't be sure which of these ISMs is going to be re-allocated, we just
# presume that the largest one could be a problem. This calculation is from
# segspt_create()->anon_swap_adjust()->page_reclaim_mem()
#
unlocked_mem_swap_pages=$(( $ani_mem_resv_pages - $ani_locked_swap_pages ))
adjusted_swap_pages=$(( $largest_ism_pages - $unlocked_mem_swap_pages ))
page_reclaim_pages=$(( $segspt_minfree_pages + $adjusted_swap_pages ))

# ignore tune.t_minarmem: it's tiny
print_pages "A restart would require" $page_reclaim_pages
print_pages "from availrmem" $availrmem_pages

if [[ $page_reclaim_pages -gt $availrmem_pages ]]; then
	ok=false
	echo "WARNING: restarting postgres might fail on this system"
else
	echo "System seems OK?"
	ok=true
fi

if [[ "$1" != "apply-workaround" ]]; then
	[[ "$ok" = "true" ]] && exit 0
	exit 1
fi

echo "Checking before applying workaround..."

# 16 Gb
if [[ $mem_pages -lt 4194304 ]]; then
	echo "Low total mem: not doing anything" >&2
	exit 1
fi

# 4 Gb
if [[ $availrmem_pages -lt 1048576 ]]; then
	echo "Low availrmem: not doing anything" >&2
	exit 1
fi

echo "Set segspt_minfree to 1Gb: yes/no?"
read ans

if [[ "$ans" != "yes" ]]; then
	echo "not doing anything" >&2
	exit 1
fi

mdb -kwe "segspt_minfree/z 0t262144"

echo "done"

mdb -ke segspt_minfree/D

exit 0
