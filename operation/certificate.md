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

- 인증서 확인
```
$ openssl x509 -in /tmp/bbsclient.crt -text 
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            c4:3f:25:cf:1c:41:eb:30:9d:06:6a:cd:31:c0:84:a2
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=USA, O=Cloud Foundry, CN=bbsCA
        Validity
            Not Before: Oct 25 10:56:04 2017 GMT
            Not After : Oct 25 10:56:04 2018 GMT
        Subject: C=USA, O=Cloud Foundry, CN=bbs client
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:db:12:f1:f4:d6:ff:f7:e5:e7:3c:3b:ba:6c:bc:
                    2b:b9:af:76:48:8b:e6:f7:34:ca:97:2d:ef:bb:34:
                    59:53:e0:c8:f8:9d:23:9e:58:e6:85:f4:7c:8a:b7:
                    78:0d:ac:3d:97:cd:98:c9:bd:a6:3e:42:7e:e5:eb:
                    e8:5b:33:06:dc:c7:a8:82:2a:05:45:f0:a9:66:f3:
                    4b:c8:a5:1a:52:26:5d:d8:eb:14:da:1c:4a:30:12:
                    36:8e:a4:9f:28:a0:22:7c:bc:52:51:61:60:98:d9:
                    e3:ab:f7:4d:06:18:70:d3:4b:95:f1:84:da:5f:3c:
                    af:19:52:07:f5:39:9d:06:17:4e:50:ef:aa:16:46:
                    25:0a:cf:52:bd:c2:c2:1d:e8:fc:c9:82:77:d1:10:
                    d6:b1:33:ea:db:36:c1:3d:3a:d4:de:f2:d3:f4:de:
                    49:6f:69:76:e1:a4:36:52:f3:6d:7a:2a:e8:7b:fa:
                    7c:12:77:e9:3c:6b:85:1a:fa:e3:7b:8b:c2:42:7a:
                    9c:4b:21:2f:6c:a0:f0:88:74:7c:a0:27:b7:e0:13:
                    d7:c2:8b:09:40:bc:47:de:d0:97:80:d2:9d:9b:93:
                    26:37:ac:3a:ca:92:67:be:bc:f6:1d:bf:ad:12:56:
                    d4:6a:bf:e3:19:2a:67:18:51:5b:59:26:ab:cc:9b:
                    22:a7
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage:
                TLS Web Client Authentication
            X509v3 Basic Constraints: critical
                CA:FALSE
                ...
```
