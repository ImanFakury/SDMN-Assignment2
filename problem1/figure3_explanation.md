# Routing Across Different Servers (Figure 3)

When the network namespaces are distributed across two distinct servers connected via a Layer 2 switch, both servers must act as independent routers for their internal container networks and exchange traffic over their external physical interfaces.

**Solution & Rules:**
1. **Host Configuration:** On both servers, assign the gateway IP to the internal bridge (`br1` on Server 1, `br2` on Server 2) and enable kernel IPv4 forwarding (`sysctl -w net.ipv4.ip_forward=1`).
2. **Layer 2 Transit:** Both Server 1 and Server 2 must have their physical network interfaces configured on the same shared Layer 2 subnet to communicate across the switch.
3. **Static Routing Rules:** The root namespace on each server requires a static route to direct outbound traffic to the remote server's container subnet.
   - **On Server 1:** Add a route directing traffic for `10.10.0.0/24` through the physical switch-facing IP address of Server 2 (`ip route add 10.10.0.0/24 via <Server_2_Physical_IP>`).
   - **On Server 2:** Add a route directing traffic for `172.0.0.0/24` through the physical switch-facing IP address of Server 1 (`ip route add 172.0.0.0/24 via <Server_1_Physical_IP>`).
