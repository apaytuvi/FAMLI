FROM ubuntu:16.04
MAINTAINER sminot@fredhutch.org

# Install prerequisites
RUN apt update && \
	apt-get install -y build-essential wget unzip python2.7 \
					   python-dev git python-pip bats awscli curl \
					   libcurl4-openssl-dev make gcc zlib1g-dev

# Set the default langage to C
ENV LC_ALL C

# Use /share as the working directory
RUN mkdir /share
WORKDIR /share

# Add files
RUN mkdir /usr/famli
ADD requirements.txt /usr/famli

# Install python requirements
RUN pip install -r /usr/famli/requirements.txt && rm /usr/famli/requirements.txt


# Install Paladin
RUN cd /usr/local && \
	wget https://github.com/twestbrookunh/paladin/archive/v1.4.1.tar.gz && \
	tar xzf v1.4.1.tar.gz && \
	rm v1.4.1.tar.gz && \
	cd paladin-1.4.1 && \
	make && \
    ln -s /usr/local/paladin-1.4.1/paladin /usr/local/bin/

# Install the SRA toolkit
RUN cd /usr/local/bin && \
	wget -q https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.8.2/sratoolkit.2.8.2-ubuntu64.tar.gz && \
	tar xzf sratoolkit.2.8.2-ubuntu64.tar.gz && \
	ln -s /usr/local/bin/sratoolkit.2.8.2-ubuntu64/bin/* /usr/local/bin/ && \
	rm sratoolkit.2.8.2-ubuntu64.tar.gz


# Add the run script to the PATH
ADD famli.py /usr/famli
ADD lib /usr/famli/lib
RUN cd /usr/famli && \
	chmod +x famli.py && \
	ln -s /usr/famli/famli.py /usr/bin/


# Run tests and then remove the folder
ADD tests /usr/famli/tests
RUN bats /usr/famli/tests/ && rm -r /usr/famli/tests/