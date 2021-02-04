
// start proxy with ssh -CfND 9090 jlevon@v

function FindProxyForURL(url, host) {

    // these are reachable
    if (localHostOrDomainIs(host, "portal.nutanix.com") ||
        localHostOrDomainIs(host, "next.nutanix.com") ||
        localHostOrDomainIs(host, "www.nutanix.com"))
	return "DIRECT";

    // If the hostname matches, send through proxy
    if (
        dnsDomainIs(host, "nutanix.com") ||
        dnsDomainIs(host, "10.53.99.199") ||
        dnsDomainIs(host, "sourcegraph.canaveral-corp.us-west-2.aws") ||
        dnsDomainIs(host, "10.49.47.176") ||
        dnsDomainIs(host, "10.41.24.115") ||
	dnsDomainIs(host, "10.37.191.151") ||
        dnsDomainIs(host, "10.41.24.97") ||
        dnsDomainIs(host, "10.41.24.97") ||
	dnsDomainIs(host, "10.49.46.190") ||

        dnsDomainIs(host, "10.41.24.94"))
        return "SOCKS5 localhost:9090";

    // DEFAULT RULE: All other traffic, use below proxies, in fail-over order.
    return "DIRECT";
}
