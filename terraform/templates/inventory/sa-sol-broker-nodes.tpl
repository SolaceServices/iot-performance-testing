[sol_brokers]
%{ for ip in solbroker-nodes-ips ~}
${ip}
%{ endfor ~}

[sol_brokers_privateip]
%{ for ip in solbroker-nodes-privateips ~}
${ip}
%{ endfor ~}