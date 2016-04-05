# https://freeswitch.org/confluence/display/FREESWITCH/FreeSWITCH+1.6+Video
FROM debian:jessie
#FROM freeswitch:latest
#MAINTAINER Ian Blenke <ian@blenke.com>

RUN perl -pi -e 's/httpredir.debian.org/cloudfront.debian.net/g' /etc/apt/sources.list
RUN apt-get update -y
RUN DEBIAN_FRONTEND=none APT_LISTCHANGES_FRONTEND=none apt-get install -y wget
#
RUN echo "deb http://files.freeswitch.org/repo/deb/debian/ jessie main" > /etc/apt/sources.list.d/99FreeSWITCH.test.list
RUN wget -O - http://files.freeswitch.org/repo/deb/debian/key.gpg |apt-key add -
RUN apt-get update -y
#
RUN DEBIAN_FRONTEND=none APT_LISTCHANGES_FRONTEND=none apt-get install -y --force-yes freeswitch-video-deps-most
#
# because we're in a branch that will go through many rebases it's
# better to set this one, or you'll get CONFLICTS when pulling (update)
RUN git config --global pull.rebase true
 
RUN git clone https://freeswitch.org/stash/scm/fs/freeswitch.git /usr/src/freeswitch.git
#clone ARDS modules
RUN git clone https://github.com/DuoSoftware/DVP-Scripts.git /usr/src/DVP-Scripts.git
RUN cd /usr/src/DVP-Scripts.git/
RUN ls /usr/src/freeswitch.git/src/
RUN ls /usr/src/freeswitch.git/src/mod/
RUN ls /usr/src/freeswitch.git/src/mod/applications/


RUN ls /usr/src/DVP-Scripts.git/
#RUN cd DVP-Scripts.git
RUN cp -a /usr/src/DVP-Scripts.git/mod_ards /usr/src/freeswitch.git/src/mod/applications/

#RUN cd /usr/src/freeswitch.git

WORKDIR /usr/src/freeswitch.git

RUN /usr/src/freeswitch.git; ./bootstrap.sh -j
RUN /usr/src/freeswitch.git; ./configure -C

RUN /usr/src/freeswitch.git; perl -i -pe 's/#formats\/mod_vlc/formats\/mod_vlc/g' modules.conf
RUN /usr/src/freeswitch.git; perl -i -pe 's/#applications\/mod_av/applications\/mod_av/g' modules.conf
RUN /usr/src/freeswitch.git; perl -i -pe 's/#applications\/mod_curl/applications\/mod_curl/g' modules.conf
RUN /usr/src/freeswitch.git; perl -i -pe 's/#applications\/mod_spy/applications\/mod_spy/g' modules.conf
RUN /usr/src/freeswitch.git; perl -i -pe 's/#formats\/mod_shout/formats\/mod_shout/g' modules.conf
RUN /usr/src/freeswitch.git; perl -i -pe 's/#xml_int\/mod_xml_curl/xml_int\/mod_xml_curl/g' modules.conf
RUN /usr/src/freeswitch.git; perl -i -pe 's/#asr_tts\/mod_flite/asr_tts\/mod_flite/g' modules.conf
RUN /usr/src/freeswitch.git; echo 'applications/mod_ards' >> modules.conf
RUN /usr/src/freeswitch.git; make
RUN /usr/src/freeswitch.git; make install
RUN /usr/src/freeswitch.git; make cd-sounds-install cd-moh-install samples

#copy ards.conf.xml files
RUN cp /usr/src/freeswitch.git/src/mod/applications/mod_ards/conf/ards.conf.xml /usr/local/freeswitch/conf/autoload_configs/
RUN rm -rf /usr/src/DVP-Scripts

ADD vid.conf /etc/sysctl.d/vid.conf
ADD run.sh /usr/local/freeswitch/run.sh
ADD startfs.sh /usr/local/freeswitch/startfs.sh
RUN chmod 777 /usr/local/freeswitch/run.sh
RUN chmod 777 /usr/local/freeswitch/startfs.sh

ENV FREESWITCH_PATH /usr/local/freeswitch

WORKDIR /usr/local/freeswitch

ENV PATH /usr/local/freeswitch/bin:$PATH

RUN useradd --system --home-dir ${FREESWITCH_PATH} --comment "FreeSWITCH Voice Platform" --groups daemon freeswitch && \
    chown -R freeswitch:daemon ${FREESWITCH_PATH} && \
    chmod -R ug=rwX,o= ${FREESWITCH_PATH} && \
    chmod -R u=rwx,g=rx ${FREESWITCH_PATH}/bin/*

# Force any derived images to use the freeswitch user.. on second thought, let's not impose that on this base image
#ONBUILD USER freeswitch

# Open the container up to the world.
#EXPOSE 5060/tcp 5060/udp 5080/tcp 5080/udp
#EXPOSE 5066/tcp 7443/tcp
#EXPOSE 8021/tcp
##EXPOSE 64535/udp 64536/udp 64537/udp 64538/udp 64539/udp 64540/udp 64541/udp 64542/udp 64543/udp 64544/udp 64545/udp
#EXPOSE 16384-32768/udp
CMD ./run.sh
#CMD /usr/local/freeswitch/bin/freeswitch -c
