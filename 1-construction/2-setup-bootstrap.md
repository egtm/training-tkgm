- [Install kubectl](#install-kubectl)
- [Install tanzu CLI](#install-tanzu-cli)
- [Set Harbro CA](#set-harbro-ca)

# Install kubectl
- [official](https://techdocs.broadcom.com/us/en/vmware-tanzu/standalone-components/tanzu-kubernetes-grid/2-5/tkg/install-cli.html)
```bash
wget http://localhost/cli/v2.5.2/kubectl-linux-v1.30.2+vmware.1.gz
gzip -d kubectl-linux-v1.30.2+vmware.1.gz
install kubectl-linux-v1.30.2+vmware.1 /usr/local/bin/kubectl
kubectl version
# Cleanup
rm kubectl-linux-v1.30.2+vmware.1.gz
```

# Install tanzu CLI
- [official](https://techdocs.broadcom.com/us/en/vmware-tanzu/standalone-components/tanzu-kubernetes-grid/2-5/tkg/install-cli.html)
```bash
# ------------------------------------------------------------------------------
# Install tanzu CLI
# ------------------------------------------------------------------------------
wget http://localhost/cli/v2.5.2/tanzu-cli-v1.5.1.tar.gz
tar xvf tanzu-cli-v1.5.1.tar.gz
install $(find ./ -name tanzu-cli-linux_amd64) /usr/local/bin/tanzu
tanzu version
# Cleanup
rm -rf v1.5.1
rm tanzu-cli-v1.5.1.tar.gz

# ------------------------------------------------------------------------------
# Setup tanzu CLI
# ------------------------------------------------------------------------------
# Setup
tanzu config eula accept
tanzu config set features.cluster.auto-apply-generated-clusterclass-based-configuration true
tanzu config set env.TANZU_CLI_CEIP_OPT_IN_PROMPT_ANSWER no
tanzu init

# ------------------------------------------------------------------------------
# Install plugin
# ------------------------------------------------------------------------------
tanzu plugin install --group vmware-tkg/default:v2.5.2
tanzu plugin list
#>  NAME                DESCRIPTION                                                        TARGET      INSTALLED  STATUS
#>  isolated-cluster    Prepopulating images/bundle for internet-restricted environments   global      v0.32.2    installed
#>  management-cluster  Kubernetes management cluster operations                           kubernetes  v0.32.2    installed
#>  package             tanzu package management                                           kubernetes  v0.32.1    installed
#>  pinniped-auth       Pinniped authentication operations (usually not directly invoked)  global      v0.32.2    installed
#>  secret              Tanzu secret management                                            kubernetes  v0.32.0    installed
#>  telemetry           configure cluster-wide settings for vmware tanzu telemetry         global      v1.1.1     installed
#>  telemetry           configure cluster-wide settings for vmware tanzu telemetry         kubernetes  v0.32.2    installed
```

# Set Harbro CA
```bash
HARBOR_FQDN=harbor-v210.lab.net
# Get a harbor CA cert
mkdir -p /etc/docker/certs.d/${HARBOR_FQDN}
curl -sk https://${HARBOR_FQDN}/api/v2.0/systeminfo/getcert > /etc/docker/certs.d/${HARBOR_FQDN}/ca.crt
# Update Tanzu CLI
tanzu config set env.TKG_CUSTOM_IMAGE_REPOSITORY ${HARBOR_FQDN}/v2.5.2
tanzu config set env.TKG_CUSTOM_IMAGE_REPOSITORY_CA_CERTIFICATE LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZnekNDQTJ1Z0F3SUJBZ0lVVDI2dFIwU0tGQ1o3TVI3dFI5T0N1UTM2Y0dNd0RRWUpLb1pJaHZjTkFRRU4KQlFBd1VURUxNQWtHQTFVRUJoTUNRMDR4RERBS0JnTlZCQWdNQTFCRlN6RVFNQTRHQTFVRUJ3d0hRbVZwYW1sdQpaekVQTUEwR0ExVUVDZ3dHVmsxM1lYSmxNUkV3RHdZRFZRUUREQWhJWVhKaWIzSkRRVEFlRncweU5UQTBNRFl3Ck9EUTJNVGRhRncwek5UQTBNRFF3T0RRMk1UZGFNRkV4Q3pBSkJnTlZCQVlUQWtOT01Rd3dDZ1lEVlFRSURBTlEKUlVzeEVEQU9CZ05WQkFjTUIwSmxhV3BwYm1jeER6QU5CZ05WQkFvTUJsWk5kMkZ5WlRFUk1BOEdBMVVFQXd3SQpTR0Z5WW05eVEwRXdnZ0lpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElDRHdBd2dnSUtBb0lDQVFEbVB6MFo4YjlOCm1ERkl4dkhsanlRTU90SDJmNnRDdjdCQ3gyaHZESTc3VHdFRDY1MWxDSkpMTUVwV2VkU25wV1F6blNqQkVsck4KV0xxSXBEVHczQXRTbnd2WisrR1NLZ3FuejlnMjlwSnhsVUVDeHZUeTRMbjZkVktsT2ZSVEk5Q2NvQUphWW1hdQpCeHRrUFlSdGw3YTIxWk96N1FsZVR2a2NGRy93WkdlaTdrdUZENkRpZkF3ZWd1cjhFVTYvVnRLaEFzSmRIdnlUCk05bHVycVFsSE5RZ0RQYjFFVEd5Q3IxMVduRTJEOGd2ai9vQXlaZTArOTRaQUxCclJuZ3Rvcm5ibEk1a25jQTIKT2pyUXBvRC9JTnNvdVFESXc0alVmTVhCZXphN1dkUStoYXozZ21idXBqKzdvNmZJY3pNZDBoRFJVUWtCM0RMOApEczhwUUVHSXBuOEQyUTdHQkNJYjdjaEUya09JK25TZkxWcXBCTjhsNUd6UDgvbUxrdEE0ME40NzBINUYxMUprCkM5SjNIWXdNQTlIYjVqRi8yaXAwQjA1OTJVbElzbzJOK1NZd052MzlPTWRwa0QvNk9iTG91ZktLYVFDaXRYL1gKWElwQzBseXhDaWNrYTV3ZWgybU1RM081Y0QvK0Vqb2dyQnJuYlN3V1NUZ3U3cUg1cGhWeGN5ZHI2WHdJd1FyUQpoSUNoa05FMTNzUFFGTlE0MnJyR0xxZkhaNXVlZ0tCMWZsOU5BZTRFWERJK3VJT3NhNDFUcDBTdkFNU3BCVzlqCmx6SnRsTVpkY2JyZ2F5RmNEbzM2bWF3Z3c0a2RWTGxQM2IrdFFXOCtLQnUrbE1MT2NoRWsyeXlYemJWV1FvQWIKTkwxMXJLeDlEcGgwUVVDem12elczeURGOUUwOWkwdGJRd0lEQVFBQm8xTXdVVEFkQmdOVkhRNEVGZ1FVYUw0Mwp2a1BrbVhhR3VsVXdabzRrc29VQjZRWXdId1lEVlIwakJCZ3dGb0FVYUw0M3ZrUGttWGFHdWxVd1pvNGtzb1VCCjZRWXdEd1lEVlIwVEFRSC9CQVV3QXdFQi96QU5CZ2txaGtpRzl3MEJBUTBGQUFPQ0FnRUFJZ0xtMXpZN0djRWUKNmlrbGJ4d1lzK2dyKzRDZEJrb1BuNVNCWUVqd3M0Z0ZqZ0xURkd0NktGSVlCeWhYT1BnYUhQMEVUeUFRTkNETQprd0pQc3gyUVh1RS9GNXcwNWZUZldEdXdmUG43b1NjLzdMWGNXNWIvZEZXWVlTL1RES1cyclpzUk5DSFpKb3loCjVjL3E3ek1IVEdycWxMSTNFbUd6cU1sbDJQRDZkckNyQ25ITWNubWpuT0QrQ3FhMlBUU0hyeGliOEhwT0hiYTcKeFNxUWJGbE9KQ2JQSjdnYWNiSWhZdkZPUGFuU3lUTHp6UzdHVlpQbTA0MDNPOHNwU3h6TGFiK3E5V09aRURMTQorV09DeTc4bWdCUkpZM3BhOXJvekk4dWVOTzBVWHV5ZWtqeGJOdnN4YkhwdmlCR3BSRkdhTFFkeWdaYVg3K2VxCi84SzdaS3RGR2gwT0ZHcEdONEJ3OWRHdGFGMDVSMHZJWUprWDR5Mk5zMXlpcWZueHhuLys2dmY5UVFRZjNYZEEKNWZRWks5eUFkUzIxV3J0WDgrVnJmV09neGtHSUhtbTM0TkxaRW9OYWtTdVJsM0liT2N4aE5HU1I0d0IyM1JjRQpKQVZjbkJoYnlUSTA5R0J3bFpiM1Z4U2tkUk03TEVNMTc3azBRQjdEdktOcU00cFd5cWY4azZsc09Ha3EvZFovClB4OUd5STVvbjN0emVmYWQwMTc2RXoxSnpNQlo4WDlxcDV0WUg5bUFZRGxKc0daeWdCanNFa3RtbzRKRzZTWXEKVW5LaUVnTUJBV2pZTmcxWUNOTForR3plZGx1d1NUQkpTWVVGUzduczZkalNqaTRXeTFOYWtwUktkUWRMTHpkVwpZcVNVKzBnbUQ2VURmNS8zZWV6SXN0TFhDZGhMK1RVPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
tanzu config set env.TKG_CUSTOM_IMAGE_REPOSITORY_SKIP_TLS_VERIFY false
#tanzu config get
```