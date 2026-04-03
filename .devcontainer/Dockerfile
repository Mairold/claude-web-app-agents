FROM node:22-bookworm

ARG CLAUDE_CODE_VERSION=latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git wget sudo jq unzip \
    iptables ipset dnsutils \
    zsh fzf ripgrep \
    python3 python3-pip python3-venv \
    libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
    libxkbcommon0 libxcomposite1 libxdamage1 libxrandr2 libgbm1 \
    libpango-1.0-0 libcairo2 libasound2 libxshmfence1 \
    poppler-utils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# JDK 21 + Maven via Adoptium
RUN curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/adoptium.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bookworm main" > /etc/apt/sources.list.d/adoptium.list && \
    apt-get update && apt-get install -y --no-install-recommends temurin-21-jdk maven && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PIP_BREAK_SYSTEM_PACKAGES=1
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH="${NPM_CONFIG_PREFIX}/bin:${PATH}"

RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}
RUN npx playwright install chromium

ENV COLORTERM=truecolor

RUN mkdir -p /home/node/.claude /commandhistory \
    && chown -R node:node /home/node/.claude /commandhistory \
    && touch /home/node/.zshrc

COPY init-firewall.sh /usr/local/bin/
COPY allowed-domains.conf /etc/claude-sandbox/
RUN chmod +x /usr/local/bin/init-firewall.sh && \
    echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" \
      > /etc/sudoers.d/node-firewall && \
    chmod 0440 /etc/sudoers.d/node-firewall

RUN mkdir -p /home/node/.claude-json-dir && \
    chown node:node /home/node/.claude-json-dir && \
    ln -s /home/node/.claude-json-dir/.claude.json /home/node/.claude.json && \
    chown -h node:node /home/node/.claude.json

USER node
WORKDIR /workspace
