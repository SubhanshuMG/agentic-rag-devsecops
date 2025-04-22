package agentic_rag.policies

import future.keywords

default allow = false

# Data validation policy
valid_input(input) {
    input.query != ""
    count(input.query) <= 1000
}

# API access control
allowed_endpoints = {
    "retriever-agent": ["/retrieve", "/health"],
    "validator-agent": ["/validate", "/metrics"]
}

allow {
    input.method == "GET"
    input.path == allowed_endpoints[input.user.role][_]
    valid_input(input)
}

# Data filtering for PII
filter_pii(response) = filtered {
    filtered := object.filter(response, func(k, v) {
        not re_match("(?i)ssn|credit_card|password", v)
    })
}