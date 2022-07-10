## Narrafirma Container image

narrafirma.com is a Participatory Narrative Inquiry:

> Participatory narrative inquiry is an approach in which groups of people participate in gathering and working with raw stories of personal experience in order to make sense of complex patterns for better decision making. PNI focuses on the profound consideration of values, beliefs, feelings, and perspectives through the recounting and interpretation of lived experience.

Based on the work of @eliza411 https://github.com/eliza411/narrafirma-docker I basically hacked together this Containerfile (podman, but should also work with docker),
had to rebuild it, since I wanted to run it on a raspberrypi

### Instructions 

- `curl -LO https://github.com/pdfernhout/narrafirma/archive/v$NF_VERSION.tar.gz`
- `sudo podman build --build-arg NF_VERSION=1.5.15 --tag foursixnine/narrafirma --rm .`
- `sudo podman create -p 8080:8080 -p 8081:8081 -e NF_SUPERUSER=changethis -e NF_PASSWORD=changethis --name narrafirma_container narrafirma:latest`
- `sudo podman generate systemd narrafirma_anna --files --name`
- `sudo cp container-narrafirma_anna.service /etc/systemd/system/`
- `sudo systemctl enable --now container-narrafirma_anna.service`
