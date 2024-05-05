<pre>
  You can use the ip route command to check the gateway IP on a host configured with both IPv4 and IPv6. Here's a bash command that will display the gateway IP addresses:


ip route | grep default
This command will show the default routes for both IPv4 and IPv6, which typically include the gateway IP addresses. If your system doesn't support the ip command, you can use route -n for IPv4 and ip -6 route show for IPv6:


route -n | grep '^0.0.0.0'
ip -6 route show | grep '^default'
These commands will output the gateway IP addresses for IPv4 and IPv6 respectively.
  
</pre>
