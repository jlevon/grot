
// start proxy with ssh -CfND 9090 jlevon@v

function FindProxyForURL(url, host) {
 
    // If the hostname matches, send through proxy
    if (dnsDomainIs(host, "joyent.us"))
        return "SOCKS5 localhost:9090";
 
 
    // DEFAULT RULE: All other traffic, use below proxies, in fail-over order.
    return "DIRECT";
}
