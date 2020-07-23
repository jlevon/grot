
// start proxy with ssh -CfND 9090 jlevon@v

function FindProxyForURL(url, host) {

    // these are reachable
    if (localHostOrDomainIs(host, "jenkins.joyent.us")) return "DIRECT";
    if (localHostOrDomainIs(host, "chat.joyent.us")) return "DIRECT";
    if (localHostOrDomainIs(host, "chatlogs.joyent.us")) return "DIRECT";
    if (localHostOrDomainIs(host, "wiki.joyent.us")) return "DIRECT";
    if (localHostOrDomainIs(host, "jira.joyent.us")) return "DIRECT";
    if (localHostOrDomainIs(host, "cr.joyent.us")) return "DIRECT";
    if (localHostOrDomainIs(host, "hound.joyent.us")) return "DIRECT";
    if (localHostOrDomainIs(host, "pwchange.joyent.us")) return "DIRECT";

    // If the hostname matches, send through proxy
    if (dnsDomainIs(host, "joyent.us"))
        return "SOCKS5 localhost:9090";

    // DEFAULT RULE: All other traffic, use below proxies, in fail-over order.
    return "DIRECT";
}
