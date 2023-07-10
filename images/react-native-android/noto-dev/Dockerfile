FROM reactnativecommunity/react-native-android:5.0

# Work directory

WORKDIR /code

################################################################################################
###
### Install RUBY
###
RUN apt-get update && apt-get -y install ruby-dev

################################################################################################
###
### Install fastlane
###

# Need g++ and make to build gem native extension (which fastlane is)
RUN apt-get install -y g++ make
# Installing bundle
RUN gem install bundle
# Installing fastlane
RUN gem install fastlane

################################################################################################
###
### Install imagemagick
###

RUN apt-get install -y imagemagick

RUN mkdir -p /.yarn
RUN chmod -R 777 /.yarn
RUN touch /.yarnrc
RUN chmod -R 777 /.yarnrc
RUN mkdir -p /.cache/yarn
RUN chmod -R 777 /.cache/yarn

RUN echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf && sysctl -p

# Work directory
COPY ./build-android.sh /build-android.sh
