FROM archlinux:latest
RUN pacman -Suy --noconfirm --needed git base-devel github-cli bc pahole cpio python
RUN useradd -m linux-cachyos_builder
USER linux-cachyos_builder
RUN mkdir /home/linux-cachyos_builder/.config
COPY modprobed.db /home/linux-cachyos_builder/.config/modprobed.db
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
