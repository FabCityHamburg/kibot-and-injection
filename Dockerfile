FROM rust:latest AS rusttools

WORKDIR /apps

RUN cd /apps && \
  git config --global user.email "buildbot@fabcity.hamburg" && \
  git config --global user.name "the fab city hamburg build bot" && \
  git clone --branch=0.9.0 https://github.com/hoijui/projvar.git && \
  git clone https://github.com/hoijui/kicad-text-injector.git

# build projvar
RUN cd /apps/projvar && \ 
  cargo build --release

# build text injector
RUN cd /apps/kicad-text-injector && \ 
  cargo build --release

# begin from final base image with kibot etc
FROM setsoft/kicad_auto:10.4-5.1.9

COPY --from=rusttools /apps/projvar/target/release/projvar /usr/local/bin/projvar
COPY --from=rusttools /apps/kicad-text-injector/target/release/kicad-text-injector /usr/local/bin/kicad-text-injector

# update debian
RUN apt-get update && apt-get -y upgrade && apt-get install -y build-essential wget git python3-pip libffi-dev qrencode fonts-liberation2
# install image-injector
RUN mkdir -p /usr/src/ && cd /usr/src && \
  git clone "https://github.com/hoijui/kicad-image-injector.git" && \
  cd kicad-image-injector && \
  pip3 install -r ./requirements.txt

