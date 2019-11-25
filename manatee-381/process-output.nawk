#!/usr/bin/nawk -f

/^Host UUID: UUID=/ {
	host = gensub(/Host UUID: UUID='(.*)'.*/, "\\1", "g");
}

/Total memory pages:/ {
	total = gensub(/.*\( (.*) Mb \).*/, "\\1", "g");
}

/^segspt_minfree_pages:/ {
	minfree = gensub(/.*\( (.*) Mb \).*/, "\\1", "g");
}

/availrmem pages:/ {
	availrmem = gensub(/.*\( (.*) Mb \).*/, "\\1", "g");
}

/would.require/ {
	required = gensub(/.*\( (.*) Mb \).*/, "\\1", "g");
	printf("%s: total:%s, segspt_minfree:%s, availrmem:%s, required:%s -> %s\n", \
	    host, total, minfree, availrmem, required,
	    (availrmem + 0 > required + 0) ? "OK" : "FAIL");
	next;
}


