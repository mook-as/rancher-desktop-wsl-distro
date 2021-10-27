NERDCTL_VERSION = 0.11.1
AGENT_VERSION = 0.1.1

distro.tar:

# Make expansion to add --build-arg for a variable if it's set.
arg = $(if $($(1)),--build-arg "$(1)=$($(1))")

args = BUILD_ID VERSION_ID NERDCTL_VERSION AGENT_VERSION

nerdctl-$(NERDCTL_VERSION).tgz:
	wget -O "$@" \
		"https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-full-${NERDCTL_VERSION}-linux-amd64.tar.gz"

rancher-desktop-guestagent-$(AGENT_VERSION):
	wget -O "$@" \
		"https://github.com/rancher-sandbox/rancher-desktop-agent/releases/download/v${AGENT_VERSION}/rancher-desktop-guestagent"

image-id: Dockerfile build.sh os-release wsl.conf nerdctl-$(NERDCTL_VERSION).tgz rancher-desktop-guestagent-$(AGENT_VERSION)
	docker build $(foreach a,$(args),$(call arg,$(a))) --iidfile "$@" --file "$<" .

container-id: image-id
	docker create --cidfile "$@" "$(shell cat "$<")" -- /bin/true

distro.tar: container-id
	docker export --output "$@" "$(shell cat "$<")"
	docker rm -f "$(shell cat "$<")"

.INTERMEDIATE: image-id container-id