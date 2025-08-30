# ips

## ipv4

- `10.1.1.0/24` - dhcp range
- `10.1.2.0/24` - static machine ips
- `10.1.3.0/24` - well known service
- `10.1.4.0/24` - load balancer ips

### static ips

- `10.1.2.2` - gaia-01
- `10.1.2.3` - gaia-02
- `10.1.2.4` - gaia-03
- `10.1.2.5` - gaia-04
- `10.1.2.6` - gaia-05

### well known ips

- `10.1.3.2` - control plane vip
- `10.1.3.3` - traefik ingress
- `10.1.3.4` - coredns
- `10.1.3.5` - k8s_gateway
- `10.1.3.6` - minecraft

## ipv6

- `2603:8080:1e00:1b02:1000::/68` - static machine ips
- `2603:8080:1e00:1b02:2000::/68` - well known services
- `2603:8080:1e00:1b02:3000::/68` - load balancer ips

### static ips

- `2603:8080:1e00:1b02:1000::1` - gaia-01
- `2603:8080:1e00:1b02:1000::2` - gaia-02
- `2603:8080:1e00:1b02:1000::3` - gaia-03
- `2603:8080:1e00:1b02:1000::4` - gaia-04
- `2603:8080:1e00:1b02:1000::5` - gaia-05

### well known ips

- `2603:8080:1e00:1b02:2000::1` - traefik ingress
- `2603:8080:1e00:1b02:2000::2` - coredns
- `2603:8080:1e00:1b02:2000::3` - minecraft
