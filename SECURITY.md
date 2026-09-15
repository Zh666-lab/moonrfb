# Security

This is an experimental protocol-library release, not a security-audited remote desktop product. Only connect to systems you own or are authorized to access.

Classic VNC authentication uses legacy DES with the first eight password bytes and does not encrypt session traffic. None security is disabled by default. Use an authenticated secure tunnel or trusted isolated network; TLS is not implemented here. No constant-time crypto guarantee is made.

Input sizes, pixels, rectangles and event queues are bounded. Applications must additionally limit connections, timeouts and CPU use. Do not log passwords or authentication challenges/responses. Report issues privately using GitHub's private vulnerability reporting if enabled; otherwise contact the maintainer before publishing exploit details. Do not put secrets into public issues.
