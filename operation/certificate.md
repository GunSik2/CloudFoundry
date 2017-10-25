# Bosh2 사용한 인증서 생성

- bbsCA.yml
``` 
variables:

- name: bbsCA
  type: certificate
  options:
    is_ca: true
    common_name: bbsCA

- name: diego_bbs_server
  type: certificate
  options:
    ca: bbsCA  #service_cf_internal_ca
    common_name: bbs.service.cf.internal
    extended_key_usage:
    - server_auth
    - client_auth
    alternative_names:
    - "*.bbs.service.cf.internal"
    - bbs.service.cf.internal

- name: diego_bbs_client
  type: certificate
  options:
    ca: bbsCA #service_cf_internal_ca
    common_name: bbs client
    extended_key_usage:
    - client_auth
```

- 인증서 생성
```
bosh interpolate bbsCA.yml   --vars-store bbs_cert.yml
```

- 인증서 보기
```
$ cat bbs_cert.yml
bbsCA:
  ca: |
    -----BEGIN CERTIFICATE-----
    MIIDGTCCAgGgAwIBAgIQM9vG3aM8aBx9ydcBNkiL7zANBgkqhkiG9w0BAQsFADA2...
    -----END CERTIFICATE-----
  certificate: |
    -----BEGIN CERTIFICATE-----
    MIIDGTCCAgGgAwIBAgIQM9vG3aM8aBx9ydcBNkiL7zANBgkqhkiG9w0BAQsFADA2...
    -----END CERTIFICATE-----
  private_key: |
    -----BEGIN CERTIFICATE-----
    MIIDGTCCAgGgAwIBAgIQM9vG3aM8aBx9ydcBNkiL7zANBgkqhkiG9w0BAQsFADA2...
    -----END CERTIFICATE-----...
```
