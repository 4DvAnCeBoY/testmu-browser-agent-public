# Runtime image — linux/amd64 pinned for Chrome compatibility
FROM --platform=linux/amd64 debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    && curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /tmp/chrome.deb \
    && apt-get install -y /tmp/chrome.deb \
    && rm /tmp/chrome.deb \
    && rm -rf /var/lib/apt/lists/*

# Download the pre-built binary from the latest release
ARG VERSION=latest
RUN REPO="4DvAnCeBoY/testmu-browser-agent-public" && \
    if [ "$VERSION" = "latest" ]; then \
        TAG=$(curl -sSf "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/'); \
    else \
        TAG="$VERSION"; \
    fi && \
    curl -sSfL "https://github.com/$REPO/releases/download/$TAG/testmu-browser-agent-linux-amd64" \
        -o /usr/local/bin/testmu-browser-agent && \
    chmod +x /usr/local/bin/testmu-browser-agent

EXPOSE 9222

ENTRYPOINT ["testmu-browser-agent"]
CMD ["serve", "--headless", "--port", "9222"]
