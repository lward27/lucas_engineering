FROM excalidraw/excalidraw:latest

COPY docker-entrypoint.sh /usr/local/bin/excalidraw-entrypoint
RUN chmod +x /usr/local/bin/excalidraw-entrypoint

ENTRYPOINT ["/usr/local/bin/excalidraw-entrypoint"]
