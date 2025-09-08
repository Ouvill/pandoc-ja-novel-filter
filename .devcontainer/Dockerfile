FROM mcr.microsoft.com/devcontainers/typescript-node:22

RUN apt-get update && apt-get -y install texlive-lang-japanese texlive-latex-extra texlive-luatex texlive-extra-utils latexmk pandoc lua5.4 && \
    npm install -g @anthropic-ai/claude-code