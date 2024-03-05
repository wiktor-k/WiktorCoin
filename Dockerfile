FROM archlinux

RUN pacman -Sy --needed --noconfirm archlinux-keyring && \
    pacman -Syu --needed --noconfirm z3 rust curl git lld pkg-config

RUN curl -sSL https://dot.net/v1/dotnet-install.sh | \
        TERM=linux /bin/bash -s -- --channel 6.0 --install-dir "/dotnet" --version latest --architecture "x64"

RUN /dotnet/dotnet tool update --tool-path "/dotnet/tools/" Boogie --version 2.15.8

RUN git clone https://github.com/move-language/move /tmp/move && cargo install --path /tmp/move/language/tools/move-cli

ENV Z3_EXE /usr/bin/z3
ENV BOOGIE_EXE /dotnet/tools/boogie
ENV DOTNET_ROOT /dotnet
ENV PATH /usr/bin:/root/.cargo/bin

RUN move --help

COPY Move.toml /coin/
COPY sources /coin/sources/
WORKDIR /coin

RUN move build
RUN move test --state_on_error
RUN move prove
