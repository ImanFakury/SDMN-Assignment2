# Routing Without a Router Namespace (Figure 2)

When the dedicated router namespace is removed, the host server's root namespace must assume the routing responsibilities to pass traffic between the `172.0.0.0/24` and `10.10.0.0/24` subnets.

**Solution & Rules:**
1. **Interface Configuration:** In the root namespace, assign the respective default gateway IP addresses directly to the virtual bridge interfaces (`172.0.0.1/24` to `br1` and `10.10.0.1/24` to `br2`).
2. **Enable IP Forwarding:** Enable IPv4 packet forwarding in the host's kernel (`sysctl -w net.ipv4.ip_forward=1`) to permit the root namespace to route traffic between its interfaces.
3. **Routing Rules:** No explicit static routes are required in the root namespace. Because both `br1` and `br2` are active interfaces attached directly to the root namespace, the host kernel automatically creates direct connected routes for both subnets and will natively route traffic between them.
