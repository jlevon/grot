
// start proxy with ssh -CfND 9090 jlevon@v

function FindProxyForURL(url, host) {

    // these are reachable
 //   if (localHostOrDomainIs(host, "jenkins.nutanix.com")) return "DIRECT";

    // If the hostname matches, send through proxy
    if (dnsDomainIs(host, "nutanix.com"))
        return "SOCKS5 localhost:9090";

    if (dnsDomainIs(host, "10.53.99.199"))
        return "SOCKS5 localhost:9090";

    if (dnsDomainIs(host, "sourcegraph.canaveral-corp.us-west-2.aws"))
        return "SOCKS5 localhost:9090";

    // DEFAULT RULE: All other traffic, use below proxies, in fail-over order.
    return "DIRECT";
}
