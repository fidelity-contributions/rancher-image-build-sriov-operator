ARG TAG="release-4.8"
ARG UBI_IMAGE=registry.access.redhat.com/ubi7/ubi-minimal:latest
ARG GO_IMAGE=rancher/hardened-build-base:v1.15.2b5

# Build the project
FROM ${GO_IMAGE} as builder
RUN set -x \
 && apk --no-cache add \
    git \
    make
ARG TAG
RUN git clone https://github.com/k8snetworkplumbingwg/sriov-network-operator
WORKDIR sriov-network-operator
RUN git fetch --all --tags --prune
RUN git branch -a
RUN git checkout remotes/origin/${TAG} -b ${TAG}
RUN make clean && make _build-manager

# Create the sriov-cni image
FROM ${UBI_IMAGE}
WORKDIR /
COPY --from=builder /go/sriov-network-operator/build/_output/linux/amd64/manager /usr/bin/sriov-network-operator
ENTRYPOINT ["/usr/bin/sriov-network-operator"]