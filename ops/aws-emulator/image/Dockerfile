# AWS's documented container recipe, with an immutable base and a locally
# downloaded, signature-verified release package. See ../README.md.
FROM public.ecr.aws/amazonlinux/amazonlinux:2023-minimal@sha256:158a9044f9dc0777f098b76c8b54346f6ed4560b9a6a416dec7a5ba3bc483af4
COPY .artifacts/aws-emulator.rpm /tmp/aws-emulator.rpm
RUN rpm -i /tmp/aws-emulator.rpm && rm /tmp/aws-emulator.rpm \
    && mkdir -p /home/emulator && chown 1000:1000 /home/emulator
LABEL org.opencontainers.image.title="AWS Emulator" \
      org.opencontainers.image.source="https://github.com/aws/aws-emulator" \
      org.opencontainers.image.revision="813af480bf7f16d5418b64e4f5644a74a7da11c5" \
      org.opencontainers.image.version="1.0.385"
USER 1000:1000
ENV HOME=/home/emulator
EXPOSE 9297
ENTRYPOINT ["aws-emulator", "--bind", "0.0.0.0", "--port", "9297", "--auth", "on", "--telemetry", "off"]
