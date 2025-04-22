# docker/retriever-agent/ssl_helpers.py
from ssl import SSLContext, CERT_REQUIRED, PROTOCOL_TLS_SERVER
from fastapi import FastAPI

def create_ssl_context() -> SSLContext:
    context = SSLContext(PROTOCOL_TLS_SERVER)
    context.load_cert_chain(
        certfile='/etc/ssl/certs/server.pem',
        keyfile='/etc/ssl/private/server-key.pem'
    )
    context.verify_mode = CERT_REQUIRED
    context.load_verify_locations(cafile='/etc/ssl/certs/ca.pem')
    context.set_ciphers('ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384')
    context.set_alpn_protocols(['h2'])
    return context

# Usage in FastAPI app
app = FastAPI(ssl_options=create_ssl_context())