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

### well known ips

- `10.1.3.2` - control plane vip
- `10.1.3.3` - traefik ingress

## ipv6

### well known ips

TODO: these should probably be in a separate subnet or something

- `2603:8080:1e00:1b02::2` - traefik ingress
